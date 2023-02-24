#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS publish
WORKDIR /src
COPY ContainerSample.csproj ./
RUN dotnet restore "./ContainerSample.csproj" --runtime alpine-x64
COPY . .

RUN dotnet publish "ContainerSample.csproj" -c Release -o /app/publish \
    --runtime alpine-x64 \
    --self-contained true \
    /p:PublishTrimmed=true \
    /p:PublishSingleFile=true

FROM mcr.microsoft.com/dotnet/runtime-deps:6.0-alpine AS final

# create a new user and change directory ownership
RUN adduser --disabled-password \
  --home /app \
  --gecos '' dotnetuser && chown -R dotnetuser /app

# impersonate into the new user
USER dotnetuser

WORKDIR /app

EXPOSE 80
EXPOSE 5000
COPY --from=publish /app/publish .
ENTRYPOINT ["./ContainerSample"]