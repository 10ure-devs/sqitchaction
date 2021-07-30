# Sqitch docker action

This action deploys schema in specified directory to target database

## Inputs

## `directory`
## `host`
## `user`
## `password`
## `database`
## `ssl-mode`

**Required** The directory where schema lives.
**Required** The database host.
**Required** The database user.
**Required** The database password.
**Required** The database name.
**Required** The database ssl mode. Default "required"


## Outputs

## `time`

The time we of deployment.

## Example usage w/ github secrets

    - name: Deploy Schema
      uses: 10ure-devs/sqitchaction@v3
      with: 
        host: ${{ secrets.DATABASE_HOST }}
        port: ${{ secrets.DATABASE_PORT }}
        password: ${{ secrets.DATABASE_PASSWORD }}
        user: ${{ secrets.DATABASE_USER }}
        ssl-mode: ${{ secrets.DATABASE_SSL_MODE }}
        directory: "./services/auth/schema"  