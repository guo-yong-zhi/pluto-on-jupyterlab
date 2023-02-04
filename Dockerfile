FROM jupyter/scipy-notebook:latest

USER root

RUN wget https://github.com/google/fonts/archive/main.tar.gz -O gf.tar.gz && \
  tar -xf gf.tar.gz && \
  mkdir -p ~/.fonts/truetype/google-fonts && \
  find $PWD/fonts-main/ -name "*.ttf" -exec install -m644 {} ~/.fonts/truetype/google-fonts/ \; || return 1 && \
  rm -f gf.tar.gz && \
  # Remove the extracted fonts directory
  rm -rf $PWD/fonts-main && \
  # Remove the following line if you're installing more applications after this RUN command and you have errors while installing them
  rm -rf /var/cache/* && \
  fc-cache -f

RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.5-linux-x86_64.tar.gz && \
    tar -xvzf julia-1.8.5-linux-x86_64.tar.gz && \
    mv julia-1.8.5 /opt/ && \
    ln -s /opt/julia-1.8.5/bin/julia /usr/local/bin/julia && \
    rm julia-1.8.5-linux-x86_64.tar.gz

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
