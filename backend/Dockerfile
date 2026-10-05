# ============================================================
# 智途AI 后端镜像（多阶段构建）
#
# 构建：docker build -t zhitu-backend ./backend
# 说明：项目编译目标是 Java 8，因此构建与运行都用 JDK/JRE 8。
#       若拉不到 maven:3.9-eclipse-temurin-8，可换成 maven:3.8-openjdk-8。
# ============================================================

# ---------- 构建阶段 ----------
FROM maven:3.9-eclipse-temurin-8 AS build
WORKDIR /app

# 先只复制 pom 并预下载依赖：只要 pom 没变，这一层就能命中缓存，
# 后续改业务代码不会重新下载整个依赖树
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -DskipTests package

# ---------- 运行阶段 ----------
FROM eclipse-temurin:8-jre
WORKDIR /app

# 容器内以非 root 运行，降低被突破后的影响面
RUN groupadd -r zhitu && useradd -r -g zhitu zhitu
COPY --from=build /app/target/*.jar app.jar
USER zhitu

EXPOSE 8080

# 生产环境关闭 SQL 日志，避免把学生数据打进容器日志
ENV SQL_LOG_IMPL=org.apache.ibatis.logging.nologging.NoLoggingImpl

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-jar", "app.jar"]
