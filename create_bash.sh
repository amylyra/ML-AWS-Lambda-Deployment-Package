#!/bin/bash

# https://sipb.mit.edu/doc/safe-shell/
# -e will make the script exit if command fails
# if you have commands that can fail without it being 
# an issue, you can append || true or || : to supress
# this behavior 
# -o pipefail causes a pipeline to produce a failure 
# return code if any command errors. Normally, pipelines 
# only return a failure if the last command errors. In
# combination with set -e, this will make your script 
# exit if any command in a pipeline errors. 

set -o -e pipefail
venv="deploypackage"

SYSTEM_REQUIREMENT() {
    # Assume all yeses
    sudo yum -y upgrade
    sudo yum -y groupinstall "Development Tools"
    sudo yum -y install blas blas-devel lapack \
    	atlas-sse3-devel gcc python27-devel \
    	lapack-devel gcc-c++ gcc-gfortran libgfortran \
	--enablerepo=epel
}

MAKE_SWAP() {
  # Free micro instance swap file
    sudo dd if=/dev/zero of=/swapfile bs=1024 count=1500000
    sudo mkswap /swapfile
    sudo chmod 0600 /swapfile
    sudo swapon /swapfile
}

MAKE_PIP() {
    pip install numpy
    pip install scipy
    pip install sklearn
    pip install pandas
    pip install --upgrade pandas
}

MAKE_SHAREDLIB() {
    libshared="./lib64/python2.7/site-packages/lib/" 
    mkdir -p $libshared || true
    #cp /usr/lib64/atlas/* $libshared
    cp /usr/lib64/atlas-sse3/*.so.3 $libshared
    cp /usr/lib64/libquadmath.so.0 $libshared
    cp /usr/lib64/libblas.so.3 $libshared
    #cp /usr/lib64/libquadmath.2so.0 $libshared
    cp /usr/lib64/libgfortran.so.3 $libshared
}

STRIP_COMPRESS(){
    # ZIP all site packages
    for dir in ./lib64/python2.7/site-packages  #\
		#./lib/python2.7/site-packages
        do 
            if [ -d $dir ]; then 
    	    find $dir/ -name "*.so" | xargs strip	
    	    pushd $dir 
    	    zip -r -9 -q ~/$venv/lambda.zip *
    	    popd
    	fi
    done

    #zip -r -9 -q --exclude=*.zip ./full.zip *
    #zip -g --exlude=boto* ~/$venv/lambda.zip *.py
}

UPLOAD(){
    aws s3 cp --profile amy ~/$venv/lambda.zip \ 
	s3://treatmentrecommendationlambda/full.zip
}

SETUP_ENV(){
    cp ~/sklearn_build/bin/lambda ~/$venv/bin/
    cp -r ~/sklearn_build/lib/python2.7/site-packages/* \
	~/$venv/lib/python2.7/site-packages/	
}

main () {
    SYSTEM_REQUIREMENT
    ##MAKE_SWAP
    ## Virtural environment
    virtualenv --python /usr/bin/python ./ --always-copy --no-site-packages
    source bin/activate

    #MAKE_PIP
    MAKE_SHAREDLIB
    STRIP_COMPRESS
    #UPLOAD
    ##SETUP_ENV

    deactivate
} 

main
