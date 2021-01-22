ARG VERSION=3.1-alpine3.10
FROM mcr.microsoft.com/dotnet/core/sdk:$VERSION 


RUN dotnet publish src/ -c Release -o ./output/api
RUN dotnet publish src/ -c Release -o ./output/handler


FROM mcr.microsoft.com/dotnet/core/aspnet:$VERSION
ENV DOTNET_RUNNING_IN_CONTAINER=true
WORKDIR /app
COPY --from=publish /app/output .