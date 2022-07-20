FROM pytorch/pytorch:1.10.0-cuda11.3-cudnn8-runtime
RUN apt-get -qq update
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgl1 \
        libglib2.0-0
#RUN apt-get update
#RUN apt-get install -qqy aptitude
#RUN apt-get install -qqy screen
#RUN apt-get install libprotobuf-dev protobuf-compiler
#RUN pip install pycuda

# install python dependencies
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt

# go home
WORKDIR /home