# Usage Example (docker-compose.yml)

```
version: '3.2'
 services:
   postgres:
     image: postgres:11
     env_file:
       - .env
   postgres-archiver:
     image: dextervip/postgres-archiver:latest
     environment:
       - BACKUP_INTERVAL=3600
       - S3_BUCKET=database-dumps/${ENV}
     env_file:
       - .env
     depends_on:
       - postgres
```

# Required Env Vars

- POSTGRES_HOST 
- POSTGRES_PORT 
- POSTGRES_DB 
- POSTGRES_USER 
- POSTGRES_PASSWORD 
- S3_BUCKET 

## Optional Env Vars
- BACKUP_INTERVAL (Defaults to 86400 seconds)
- AWS_S3_ENDPOINT (You could use a third-party cloud storage with S3 Compatible APIs Eg.: https://s3.us-west-001.backblazeb2.com)
- AWS_DEFAULT_REGION=us-west-001
- AWS_ACCESS_KEY_ID (If you don't have IAM role or credential file)
- AWS_SECRET_ACCESS_KEY
