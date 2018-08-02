# Use an poldracklab/fitlins as a parent image
FROM poldracklab/fitlins

# Set user back to root
USER root
RUN chown -R root /src /work

# Install neurodebian/datalad
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install datalad -yq

RUN git config --global user.name "Neuroscout"
RUN git config --global  user.email "user@example.edu"


# Install additional neuroscout + dependencies
RUN /bin/bash -c "source activate neuro \
      && pip install -q --no-cache-dir -e /src/fitlins[all]" \
    && sync

# Copy the current directory contents into the container at /app (using COPY instead of ADD to keep it lighter)
COPY [".", "/src/neuroscout"]

RUN /bin/bash -c "source activate neuro \
      && pip install -q --no-cache-dir -e /src/neuroscout/" \
    && sync

RUN /bin/bash -c "source activate neuro \
      && pip install -q --no-cache-dir --upgrade -r /src/neuroscout/requirements.txt" \
    && sync


WORKDIR /work

# Change entrypoint to neuroscout
ENTRYPOINT ["/neurodocker/startup.sh", "neuroscout"]
