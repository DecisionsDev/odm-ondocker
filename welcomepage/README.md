
# Configuration

You must configure your server to have a app.properties file
e.g. for Liberty:
> server.xml: 
>    ``` 
>    <library id="config">
>    <folder dir="${server.config.dir}\config" />
>    </library>
>    <application id="odm_ondocker_webpage_war_exploded" location="${odm-ondocker}/welcomepage/target/odm-ondocker-webpage-1.0-SNAPSHOT" name="odm_ondocker_webpage_war_exploded" type="war">
>    <classloader privateLibraryRef="config" />
>    </application>
>    ```


And the app.properties should contain those 2 keys:
> app.properties
> ```
> dashboard=true
> redirect_url=/DecisionRunner
> ```
> `dashboard` is a boolean to say if we should display the Dashboard view.
> In case of `dashboard` is false, `redirect_url` must be set as the url to redirect.