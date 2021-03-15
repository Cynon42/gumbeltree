// here is an attemp to make a regression tree using
// gumbel softmax
data {
  int<lower=0> N;//number of rows or samples
  int K;// number of features
  vector[N] y;// the samples of the target function
  matrix[N,K] X; // the features or design matrix. continuous features normalised to normal(0,1)
  int L; // number of levels in the tree, order of tree
  real T; // temperature to run the gumbel softmax approximation of a one-hot
          // this is a critical hyperparameter that defines how easily the model can traverse between modes,
          // or between trees that are a good fit, but are in different parts of parameter space
}
transformed data{
  // need to add column of ones to the design matrix
  // all binary features incl the column of ones need to be replaced with (-100,100) so that C will never be outside the range
  // gumbel parameters are k+1 as a result
  //gumbel softmax used to select a feature,
  //or select "no feature" wich is to select the first feature which is always 1
  // this allows for an option that the node does not split i.e.
  // always select the left branch
  // if another feature is selected, then the logistic function is used
  // to find a cutoff point on that feature with which to branch the node
  //int constant=2;
  int NL=1;// number of possible leaves
  int NW;// number of nodes or weights or choices in the tree

  for (i in 1:L){
    NL = NL*2;// can only make integer 2^L inside a loop
  }

  NW=NL-1;

}

// The main problem is referring to the tree

parameters {
  real<lower=0> sigma;// assume gaussian error in y for a minute
  vector[K] G[NW];//number of gumbel samples needed to select a feature at each node
  simplex[K] P[NW];//probability vector indicating the probability of selecting each feature at each node, each group adds to 1 i.e. simplex

  vector[NW] C; //for each feature selected we need a cutoff point
  vector[NL] mu;// mean of Y at each leaf
}
model {
  vector[N] F; //the estimation of Y given X i.e. y^=F(X)
  matrix[NW,K] H; // one hot to select a feature at each node
  matrix[NW,N] w; //calculation of the weight for each node for each sample
  matrix[NL,N] temp; //temporary store of tree calculations
                      // after processing, the first row of temp becomes
                      //the estimation of Y given X i.e. y^=F(X)
  int c;// local integer parameter
  int c2;// local integer parameter
  for (j in 1:NW){
      H[j] = softmax( (log(P[j])*(T^2 + T +1) / (T+1) + G[j])/T)' ;
      // selects a parameter using the approximate one-hot dot producted against a specific X[i], adds a cutoff constant and applies a logistic to return (~0,~1)
  }
  // this is effectively (approximately) choosing which branch of the tree to traverse, based on a cutoff applied to a selected feature
  w=inv_logit(10*((H*X')+rep_matrix(C,N)));

  // start at the bottom of the tree and work upwards
  // at the end of the loop temp[1] is the result of applying the tree to X[i]
  temp = rep_matrix(mu,N) ;
  for (j in L:1){
   c=1;
   for (k in 1:(j-1)){
     c = c*2;// can only make integer c = (2^(j-1)) inside a loop
   }

   for (k in 1:c){
     c2=1;
     for (l in 1:j){
       c2 = c2*2;// can only make integer c2 = 2^j inside a loop
     }
     temp[k]=w[k+NW-c2+1] .* temp[2*k-1] + (1-w[k+NW-c2+1]) .* temp[2*k]; // cycling through the tree and calculating which leaf is retained based on w
   }
  }

  y ~ normal(temp[1]', sigma);// assuming that y is a function that ranges (-inf,+inf)
  for (i in 1:NW){
    G[i]~gumbel(0,1); // each vector of gumbels used to create a one-hot
  }
  C~normal(0,1); //features in the design matrix are normalised so the cutoffs should be normalised I suggest
  //P needs a prior and should have a U shaped simplex prior
}
