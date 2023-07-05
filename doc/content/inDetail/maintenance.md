# Maintenance

Describe below what is required to maintain this documentation / workflow.

## How to render

Render a fresh local version of the documentation with:
```
cd doc
sphinx-build -a -b html . _build/
```

Check ancors for internal linking / referencing:
```
myst-anchors -l auxiliaryscripts.md
>> <h1 id="auxiliary-scripts"></h1>
>> <h2 id="aux_migratefromscratchsh"></h2>
>> <h2 id="aux_untarmanytarssh"></h2>
>> <h2 id="aux_restagetapesh"></h2>
>> <h2 id="aux_gzipsh-and-aux_gunzipsh"></h2>
>> <h2 id="aux_sha512sumsh"></h2>
```
Than use links like:
```
[aux_UnTarManyTars.sh](REL/PATH/TO/auxiliaryscripts.md#aux_untarmanytarssh)
```


## How to CI/CD

[TBE]