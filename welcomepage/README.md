
# Configuration

You must configure your Liberty server to have an app.properties file:

- server.xml:
```xml
<library id="config">
  <folder dir="${server.config.dir}\config" />
</library>
<application id="odm_ondocker_webpage_war_exploded" location="${odm-ondocker}/welcomepage/target/odm-ondocker-webpage-1.0-SNAPSHOT" name="odm_ondocker_webpage_war_exploded" type="war">
  <classloader privateLibraryRef="config" />
</application>
```

- app.properties file should contain those 2 keys:
```bash
dashboard=false
redirect_url=/DecisionRunner
```

  > `dashboard` is a boolean to say if we should display the Dashboard view.
  > In case of `dashboard` is false, `redirect_url` must be set to the url to redirect.
