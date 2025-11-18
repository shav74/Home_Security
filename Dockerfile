# Dockerfile
FROM eclipse-temurin:17-jdk-jammy

# Set a non-root user for Gradle
ARG USER_NAME=gradle
ARG USER_HOME=/home/${USER_NAME}
RUN useradd -ms /bin/bash ${USER_NAME}

# ---------- Environment ----------
ENV ANDROID_HOME=${USER_HOME}/android-sdk \
    ANDROID_SDK_ROOT=${USER_HOME}/android-sdk \
    GRADLE_USER_HOME=${USER_HOME}/.gradle \
    DEBIAN_FRONTEND=noninteractive

ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator

# ---------- Dependencies ----------
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget unzip git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ---------- Install Android SDK command-line tools ----------
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && cd /tmp \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm cmdline-tools.zip

# Accept licenses + install SDK components
USER ${USER_NAME}
WORKDIR ${USER_HOME}

# You can change these to match your project
ENV ANDROID_API_LEVEL=34
ENV ANDROID_BUILD_TOOLS_VERSION=34.0.0

RUN yes | sdkmanager --licenses || true

RUN sdkmanager \
    "platform-tools" \
    "platforms;android-${ANDROID_API_LEVEL}" \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

# ---------- Project workdir ----------
WORKDIR /workspace

# Default command (you can override in CI)
CMD ["bash"]
