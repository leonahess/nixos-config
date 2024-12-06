list generations (https://nix.dev/manual/nix/2.22/command-ref/new-cli/nix3-profile-history):
```
nix profile history --profile /nix/var/nix/profiles/system
```

delete generations (https://nix.dev/manual/nix/2.22/command-ref/new-cli/nix3-profile-wipe-history):
```
sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 14d
```

collect garbage:
```
nix-collect-garbage
```

create python venv
```
nix-shell -p python3 --command "python -m venv .venv --copies"
```