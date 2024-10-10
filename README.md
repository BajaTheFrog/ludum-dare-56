# Ludum Dare 56

## Running locally

```
docker compose up --build
```

This will start the game server and a webserver hosting the client.
Open http://localhost:8080 in a browser to play.

## Multiplayer test page

The docker compose web server also includes a handy multiplayer
testing page that runs 4 instances of the game at the same time.
After starting the server navigate to:

http://localhost:8080/multitest
