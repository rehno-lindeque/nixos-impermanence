# NixOS impermanence

Additional options for [NixOS](https://nixos.org) modules when used in combination with [nix-community/impermanence](https://github.com/nix-community/impermanence).

For Home Manager options see [rehno-lindeque/home-manager-impermanence](https://github.com/rehno-lindeque/home-manager-impermanence).

## Example

```nix
{
  environment.automaticPersistence.normal.path = "/persistence";

  # Don't persist /etc/machine-id at all
  environment.machineId.persistence = {};

  # Include all network manager state at the normal persistence level
  # (by default it would only retain /var/lib/NetworkManager/system-connections at the normal persistence level, losing wifi leases etc)
  networking.networkmanager.persistence = {
    normal.directories = [ "/var/lib/NetworkManager" ];
  };

  # The usual impermanence options still work as before
  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/var/log"
    ];
  };
}
```

## Contribute

### Future

I don't like to maintain software like this on my own. My hope is that [nix-community](https://github.com/nix-community) would be willing to take ownership of this repo and help to establish best practices.

### Best practices

In order to make this set of defaults useful we need to have some basic guidelines.
What exactly those guidelines should be is still unclear (help wanted!), but we likely want to:

* Give programs default access to files that are clearly owned by them
* Be explicit about access to files that are not clearly owned by a program

#### Testing for files that should be persisted

`ncdu` can be used to discover files that are not bind mounted.

```shell
ncdu -x /

# or

nix run nixpkgs#ncdu -- -x /
```

#### Monitoring which programs are accessing a specific file

`auditd` can be used to keep track of when a file is accessed.

#### Monitoring which files are accessed by a specific program

`strace` can be used to monitor a specific process for the files it accesses.

## Learn

* [Impermanence project](https://github.com/nix-community/impermanence)
* [Impermanence wiki](https://nixos.wiki/wiki/Impermanence)
* Elis Hirwin's blog:
  * [tmfs as root](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/)
  * [tmfs as home](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/)
* Graham Christensen's blog:
  * [Erase your darlings](https://grahamc.com/blog/erase-your-darlings)
