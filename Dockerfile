FROM jupyter/scipy-notebook:latest

USER root
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.2-linux-x86_64.tar.gz && \
    tar -xvzf julia-1.7.2-linux-x86_64.tar.gz && \
    mv julia-1.7.2 /opt/ && \
    ln -s /opt/julia-1.7.2/bin/julia /usr/local/bin/julia && \
    rm julia-1.7.2-linux-x86_64.tar.gz

USER ${NB_USER}

COPY --chown=${NB_USER}:users ./plutoserver ./plutoserver
COPY --chown=${NB_USER}:users ./environment.yml ./environment.yml
COPY --chown=${NB_USER}:users ./setup.py ./setup.py
COPY --chown=${NB_USER}:users ./runpluto.sh ./runpluto.sh

RUN julia -e "import Pkg; Pkg.add([\"PlutoUI\", \"Pluto\", \"WordCloud\", \"HTTP\", \"ImageIO\", \"Images\"]); Pkg.precompile()"

RUN jupyter labextension install @jupyterlab/server-proxy && \
    jupyter lab build && \
    jupyter lab clean && \
    pip install . --no-cache-dir && \
    rm -rf ~/.cache
