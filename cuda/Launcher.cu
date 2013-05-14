#include <stdio.h>
#include <stdlib.h>
#include "Rkf45.hu"
#include "Customers.hu"
#include <time.h>

#include "clireSimulatedIRPaths.hu"

/*** CUDA ERROR CHECK ***/
#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, char *file, int line, bool abort=true)
{
   if (code != cudaSuccess) 
   {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

/**************************** HOST ******************************/

//Sorting
int compare(const void *l,const void *r)
{
  CUS* lv = (CUS*)l;
  CUS* rv = (CUS*)r;
  int value = lv->policy - rv->policy;
  if (value == 0)               // Out comment to take away age sorting
    value = lv->age - rv->age;  //
  return value;
}

void sort(CUS *c,int l) {
  qsort(c,l,sizeof(CUS),compare);
}

//Calculate the number of kernels
int get_n_host(dim3 block_dim,dim3 grid_dim) {
  return grid_dim.x * grid_dim.y * grid_dim.z * block_dim.x * block_dim.y * block_dim.z; 
}

// Host code
int main(int argc, char const *argv[]) {

  int n_kernels = 1;
  int gridx = 1;
  int gridy = 1;
  int max_policies = 1;
  int n_yc = 1;
  int pop = 1;
    
  if (argc>1) {
      n_kernels = atoi(argv[1]);
  }

  if (argc>2) {
      gridx = atoi(argv[2]);
  }

  if (argc>3) {
      gridy = atoi(argv[3]);
  }

  if (argc>4) {
      max_policies = atoi(argv[4]);
  }

  if (argc>5) {
      n_yc = atoi(argv[5]);
  }

  if (argc>6) {
      pop = atoi(argv[6]);
  }

  /********** 0. SETUP **********/
  dim3 block_dim(1,1,1); //Number of threads per block // 320 seems to be best
  dim3 grid_dim(gridx,gridy,1);  //Number of blocks per grid (cc. 1.2 only supports 2d)
  int kernel_size = get_n_host(block_dim,grid_dim);
  int nsize = kernel_size*n_kernels; 
  int c = nsize/n_yc; // number of customers

  printf("%i kernels * %i calcs / %i ir_paths= %i customers\n",n_kernels,kernel_size,n_yc,c);

  /********* -2. GENERATE DATA ***/
  srand(19); //seed

  CUS* cuses = (CUS*)malloc(sizeof(CUS)*c);

  int i=0;
  int id=0;
  while(i < c) {
      int age = 30;//5 + rand()%30; //30
      int end_year = 50;
      int start_year = 0;
      int cj = min(i+max_policies,c);
      for(int j=i;j<cj;j++) {
          cuses[j].id = id;
          cuses[j].age = age;
          cuses[j].end_year = end_year;
          cuses[j].start_year = start_year;

          cuses[j].policy = pop;//5;//1+i%6;//1+rand()%6;
          cuses[j].neqn = 1;
          if (cuses[j].policy >= 5) {
            cuses[j].neqn = 2;
          }
          i++;
      }
      id++;
  }

  //double* collected_results = (float*) malloc(id*sizeof(float));

  /****** GENERATE YIELD CURVES ******/
  double* dev_yieldCurves;
  generateIRPaths(n_yc,50, &dev_yieldCurves,rand()%300); //n_irPaths, years, steps per year, yieldcurve, seed
  double* collected_results = (double*) malloc(id*sizeof(double));


  /********* -1. SORT DATA *******/
  sort(cuses,c);// sorting

  /********** 1. MALLOC HOST  **********/
  // Data on the host and the device, respectively
  double* result = (double*) malloc(nsize*sizeof(double));
  int* neqn = (int*) malloc(c*sizeof(int));
  int* policy = (int*) malloc(c*sizeof(int));
  int* age = (int*) malloc(c*sizeof(int));
  int* end_year = (int*) malloc(c*sizeof(int));
  int* start_year = (int*) malloc(c*sizeof(int));

  //Pack
  for(int i = 0;i < c;i++) {
    policy[i] = cuses[i].policy;
    neqn[i] = cuses[i].neqn;
    age[i] = cuses[i].age;
    end_year[i] = cuses[i].end_year;
    start_year[i] = cuses[i].start_year;
  }

  for(int i = 0;i < nsize;i++) {
    result[i] = 0.0f;
  }

  ///********** 2. MALLOC DEVICE  **********/
  clock_t start1 = clock();

  double *dev_result;
  int *dev_neqn;
  int *dev_policy;
  int *dev_age;
  int *dev_end_year;
  int *dev_start_year;
  gpuErrchk( cudaMalloc((void**)&dev_result, sizeof(double) * nsize));
  gpuErrchk( cudaMalloc((void**)&dev_neqn, sizeof(int) * c));
  gpuErrchk( cudaMalloc((void**)&dev_policy, sizeof(int) * c));
  gpuErrchk( cudaMalloc((void**)&dev_age, sizeof(int) * c));
  gpuErrchk( cudaMalloc((void**)&dev_end_year, sizeof(int) * c));
  gpuErrchk( cudaMalloc((void**)&dev_start_year, sizeof(int) * c));

  /********** 3. COPY HOST TO DEVICE  **********/
  // Copy data to the device
  gpuErrchk( cudaMemcpy(dev_neqn, neqn, sizeof(int) * c, cudaMemcpyHostToDevice));
  gpuErrchk( cudaMemcpy(dev_policy, policy, sizeof(int) * c, cudaMemcpyHostToDevice));
  gpuErrchk( cudaMemcpy(dev_age, age, sizeof(int) * c, cudaMemcpyHostToDevice));
  gpuErrchk( cudaMemcpy(dev_end_year, end_year, sizeof(int) * c, cudaMemcpyHostToDevice));
  gpuErrchk( cudaMemcpy(dev_start_year, start_year, sizeof(int) * c, cudaMemcpyHostToDevice));

  /********** 4. CUSTOMERS HOLDS POINTERS TO DEVICE **********/
  //Used to hold the pointers
  CUSTOMERS customers;
  customers.neqn = dev_neqn;
  customers.policy = dev_policy;
  customers.age = dev_age;
  customers.end_year = dev_end_year;
  customers.start_year = dev_start_year;

  //********* 5. TIMING START ************/
  //Normal timing
  clock_t start2 = clock();

  //Cuda timing
  cudaEvent_t cuda_start, cuda_stop;
  float cuda_time;
  cudaEventCreate(&cuda_start);
  cudaEventCreate(&cuda_stop);
  cudaEventRecord( cuda_start, 0 );

  int offset = 0;
  /********** 6. LAUNCH WITH CUSTOMERS AND RESULT *********/
  for(int i = 0; i < n_kernels; i++) {
    gpu_kernel <<<grid_dim, block_dim>>>(offset,customers,dev_result,dev_yieldCurves,n_yc,c); // GPU
    offset+=kernel_size;
  }

  /********** 7. TIMING ENDS *********/
  //Cuda timing
  cudaEventRecord( cuda_stop, 0 );
  cudaEventSynchronize( cuda_stop );
  cudaEventElapsedTime( &cuda_time, cuda_start, cuda_stop );
  cudaEventDestroy( cuda_start );
  cudaEventDestroy( cuda_stop );
  
  /********** 8. COPY RESULT FROM DEVICE TO HOST *********/
  clock_t start3 = clock();
  // Copy the result back from the device
  gpuErrchk( cudaMemcpy(result, dev_result, sizeof(double) * nsize, cudaMemcpyDeviceToHost));

  /********** 8,5. EXTRA TIMING *********/
  //Normal timing

  /*********** COLLECT RESULTS **********/
  //for(int i = 0;i < c;i++)
  //  collected_results[cuses[i].id] += result[i];
  
  for(int i = nsize-10;i < nsize;i++)
    printf("%i: %11.7f \n",i,result[i]);

  clock_t end = clock();
  float time1 = (float) (end - start1) * 1000.0f / CLOCKS_PER_SEC;
  float time2 = (float) (end - start2) * 1000.0f / CLOCKS_PER_SEC;
  float time3 = (float) (end - start3) * 1000.0f / CLOCKS_PER_SEC;
  /********** 9. PRINT HOST RESULT  *********/
  //for(int i = 0;i < id;i++)
  //  printf("%i: %11.11f \n",i, result[i]);

  //for(int i = id-20;i < id;i++)
  //  printf("%i: %11.7f \n",i, collected_results[i]);

  /*
  for(int i = 0; i < 51; i++) {
    printf("%i: %.7f\n",i, result_cpu[i]);
  }
  */

  printf("%i kernels * %i calcs = %i customers\n",n_kernels,kernel_size,nsize);
  //printf("TIME: %f, CUDA_TIME: %f\n",time,cuda_time);
  printf("TIME1: %f\n",time1);
  printf("TIME2: %f\n",time2);
  printf("TIME3: %f\n",time3);

  /********** 10. FREE MEMORY   *********/
  free(result);
  free(policy);
  free(neqn);
  free(age);
  free(end_year);
  free(start_year);
  gpuErrchk( cudaFree(dev_result));
  gpuErrchk( cudaFree(dev_policy));
  gpuErrchk( cudaFree(dev_neqn));
  gpuErrchk( cudaFree(dev_age));
  gpuErrchk( cudaFree(dev_end_year));
  gpuErrchk( cudaFree(dev_start_year));

  cudaDeviceReset();
  return 0;
}
