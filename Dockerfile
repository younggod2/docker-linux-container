FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color
ENV PATH="/usr/games:$PATH"

# Разрешаем установку man-страниц и документации (по умолчанию заблокировано в Docker-образе)
RUN rm -f /etc/dpkg/dpkg.cfg.d/excludes

# Устанавливаем русскую локаль
RUN apt-get update && apt-get install -y locales && \
    sed -i '/ru_RU.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen ru_RU.UTF-8

ENV LANG=ru_RU.UTF-8
ENV LC_ALL=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru

# Обновляем систему и устанавливаем базовые инструменты для изучения Linux
# Пакеты отсортированы алфавитно для лучшей читаемости и предотвращения дубликатов
RUN apt-get update && apt-get install -y \
    bash-completion \
    coreutils \
    curl \
    gawk \
    git \
    htop \
    iproute2 \
    iputils-ping \
    less \
    man-db \
    manpages \
    nano \
    net-tools \
    sudo \
    tree \
    vim \
    wget \
    zsh \
    && mandb --create
# Не удаляем /var/lib/apt/lists/* — чтобы apt install работал без apt update
    
# Создаем рабочую директорию
WORKDIR /workspace

# Устанавливаем Oh My Zsh (неинтерактивно)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Копируем локальный .zshrc в образ
COPY .zshrc.local /root/.zshrc

# Адаптируем .zshrc для Docker окружения
RUN sed -i 's|export ZSH="\$HOME/.oh-my-zsh"|export ZSH="/root/.oh-my-zsh"|' /root/.zshrc && \
    echo '' >> /root/.zshrc && \
    echo '# Кастомное приглашение для Docker (переопределяет тему)' >> /root/.zshrc && \
    echo 'export PS1="%B%F{green}%n@linux-lab%f:%F{blue}%~%f%b$ "' >> /root/.zshrc

CMD ["/bin/zsh"]
