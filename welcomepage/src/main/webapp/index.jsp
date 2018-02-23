<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>WebSphere Application Server V16.0.0.3</title>
  <style>
    body{
      color: white;
      display: block;
      font-family: Helvetica, Arial, sans-serif;
      font-size: 1rem;
      font-weight: 100;
      height: 100%;
      margin: 0;
      padding: 0;
      position: absolute;
      top: 0;
      width: 100%;
      z-index: 1;
    }
    a{
      color: inherit;
    }
    a:hover{
      cursor: pointer;
      opacity: 0.85;
    }
    a:active{
      opacity: 0.7;
    }
    article{
      margin-left: 75px;
      max-width: 1200px;
    }
    h1{
      color: white;
      font-size: 3.814rem;
      font-weight: lighter;
      margin: 0;
      text-align: left;
    }
    h2{
      color: white;
      font-size: 1.56rem;
      font-weight: lighter;
      line-height: 2.2rem;
      margin: 0;
      text-align: left;
    }
    h3{
      font-size: 1rem;
      font-weight: lighter;
      line-height: 1.7rem;
      margin: 0;
      text-align: left;
    }
    p{
      margin-bottom: 40px;
    }
    hr{
      background-color: white;
      border: 0;
      height: 1px;
      margin: 20px 0 28px 0;
      width: 70px;
    }
    section, footer{
      margin: 30px auto;
      position: relative;
      width: 100%;
      z-index: 5;
    }
    ul{
      display: block;
      list-style-type: none;
      margin: 18px 0 0 0;
      padding: 0;
      position: relative;
      text-indent: 0;
    }
    ul li{
      line-height: 1.8rem;
    }
    .background{
      background-color: #4178BE;
      height: 100%;
      max-height: 700px;
      left: 0;
      position: fixed;
      top: 0;
      width: 100%;
      z-index: 4;
    }
    .secondary{
      color: #DEDEDE;
    }
    #welcome-section img{
      display: inline;
      margin: 0 0 5px -6px;
      padding: 20px 0 0 0;
      width: 100px;
    }
    #welcome-section{
      margin: 75px 0 0 0;
    }
    #welcome-section .secondary{
      color: #1A304C;
    }
    #welcome-section h3{
      display: inline-block;
    }
    #resources{
      background-color: #2A4E7B;
      margin: 101px 0 0 0;
    }
    #resources article{
      padding: 50px 0 55px 0;
    }
    #resources ul li{
      width: 180px;
    }
    #resources ul li:hover{
      cursor: pointer;
      text-decoration: underline;
    }
    footer{
      background-color: #152935;
      display: block;
      margin: 0;
    }
    footer article{
      padding: 50px 0 65px 0;
    }
    footer img{
      display: inline-block;
      opacity: 0.5;
      width: 90px;
    }
    footer p{
      display: inline-block;
      font-size: 0.7rem;
      padding: 0 50px;
      max-width: 700px;
      opacity: 0.5;
    }
    #footer-extra-background{
      background-color: #152935;
      bottom: 0;
      margin: 0;
      position: absolute;
      width: 100%;
      height: 100%;
      z-index: -1;
      position: fixed;
    }
  </style>
</head>
<body>
    <div class="background"></div>

    <section id="welcome-section">
      <article id="welcome-section-content">
        <img src="images/ODM_icon.png">
        <h1>Welcome to Liberty</h1>
        <h2 class="secondary">WebSphere Application Server V16.0.0.3</h2>
            <h3>Available applications</h3>
            <ul>
              <li>Decision Server Console: <a href="/res">/res</a></li>
              <li>Decision Server Runtime: <a href="/DecisionService">/DecisionService</a></li>
              <li>Decision Center Business Console: <a href="/decisioncenter">/decisioncenter</a></li>
              <li>Decision Center Enterprise Console: <a href="/teamserver">/teamserver</a></li>
              <li>Decision Runner: <a href="/DecisionRunner">/DecisionRunner</a></li>
            </ul>
      </article>
    </section>

    <section id="resources">
      <article>
        <h2>Additional Resources</h2>
        <ul>
          <li><a href="http://wasdev.net/?wlp=welcome">WASdev Community</a></li>
          <li><a href="http://www14.software.ibm.com/webapp/wsbroker/redirect?version=phil&product=was-nd-mp&topic=cwlp_about">Liberty Documentation</a></li>
          <li><a href="http://wasdev.net/answers/?wlp=welcome">WASdev Forum</a></li>
        </ul>
      </article>
    </section>

    <footer>
      <article>
        <img src="images/ibm-white-logo-small.png">
        <p id="footer-copy">
          Licensed Materials &#8212 Property of IBM &copy Copyright IBM Corp.
          1997, 2015. All Rights Reserved. IBM, and the IBM logo are
          trademarks or registered trademarks of International Business
          Machines Corp., registered in many jurisdictions worldwide. Other
          product and service names might be trademarks of IBM or other
          companies. A current list of IBM trademarks is available on the Web
          at <span class="underline">Copyright and trademark information.</span>
        </p>
      </article>
    </footer>

    <div id="footer-extra-background"></div>
</body>

<!-- The call below attempts to get a latest release marker file from a specific location. -->
<!-- It's expected that the returned object will be a piece of JavaScript defining a       -->
<!-- variable called latestReleasedVersion that contains the following fields:             -->
<!-- version: The version number of the latest released product                            -->
<!-- availableAt: The URL where you can get the latest version (from a Web Browser)        -->
<!-- availableAtLabel: The label to show on the anchor tag                                 -->
<script type="text/javascript" src="https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp_ga_latestversion.js"></script>
<script type="text/javascript">
    var urlForCssEnhancements = "https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/adminCenter-welcome.css";
    var isLibertyUpdateAvailable = false;
    function doVersionCheck(latestVersion) {
        // Check that the remote file was located
        // and contains the required version details
        if (latestVersion != null && latestVersion.productName != null
            && latestVersion.availableFrom != null
            && latestVersion.version != null) {

            // Check if the online version differs from this current version
            if ("16.0.0.3" !== latestVersion.version) {
                isLibertyUpdateAvailable = true;
            }
        }
    }
    doVersionCheck(latestReleasedVersion);
</script>
<script type="text/javascript" src="https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/adminCenter-welcome.js"></script>

</html>
