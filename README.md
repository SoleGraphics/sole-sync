# SOLE-SYNC

A bash-based rsync helper for syncing local and remote sites.


## Global script setup
1. Clone this repository -or- just copy the `sole-sync.sh` script to your local machine.
2. Make the file executable `chmod +x sole-sync.sh`
3. If the file is not in a location that exists in your bash paths, we suggest making a symbolic link from a location that typically is: `cd /usr/local/bin/ && ln -s <path_to_your_script>/sole-sync.sh sole-sync.sh`
4. Create an bash alias for it:
   1. Run: `nano ~/.bash_profile`
   2. Add this to your bash_profile: `alias sole-sync="sole-sync.sh"`
   3. Run: `source ~/.bash_profile`
5. 👏🏼 - Thats the global setup. You can now run `sole-sync [options]` from anywhere.

## Per-site configuration
From any of your local website project directories, you can create `sync-exclude` or `sync-preset` files. The ones mentioned here are loaded by default if they exist or aren't specified via command options override.

### Presets


**Default preset:**

* copy `sync-preset-example` to `sync-preset` and put your default credentials in.
* The default preset is loaded well, by default. run
 ```
 sole-sync [options]
 ```

**Alternate preset(s):**

* copy `sync-preset-example` to `sync-preset-staging` and put your staging credentials in.
* to use the staging preset, run:
```
sole-sync --preset sync-preset-staging [options]
```

### Excludes

* copy `sync-exclude-example` to `sync-exclude`
* Modify this as needed to ensure you aren't syncing files / folders you don't want to or should be.
* Just like presets, you can create and specify more than default as desired, i.e. `sync-preset-staging`
```
sole-sync --exclude sync-exclude-staging
```
* If you don't want to remember that everytime, you can just add the following to the preset file to remeber that preset uses a separate exclude file:
```
exclude=sync-exclude-staging
```

## Usage
* Documentation: `sole-sync --help`
* Tip: We suggest that `path` and `src` always contain trailing slashes
