<%--
    Licensed to the Apache Software Foundation (ASF) under one or more
    contributor license agreements.  See the NOTICE file distributed with
    this work for additional information regarding copyright ownership.
    The ASF licenses this file to You under the Apache License, Version 2.0
    (the "License"); you may not use this file except in compliance with
    the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>IBM ODM</title>
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
      font-size: 3rem;
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
      margin: 0 0 18px 0;
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

    .presentation-container {
      margin-top: 15px;
    }
    .presentation-content {
      display: inline-block;
      vertical-align: top;
    }
    .presentation-content.right {
      padding-left: 10px;
      margin-left: 10px;
      border-left: 2px solid #1A304C;
    }
    .loan-server-hidden {
      display: none;
    }
  </style>
</head>
<body>
    <div class="background"></div>

    <section id="welcome-section">
      <article id="welcome-section-content">
        <img src="images/ODM-icon.png">
        <h1>Welcome to IBM Operational Decision Manager</h1>

        <div class="presentation-container">
          <div class="presentation-content left">
            <h2 class="secondary">Developer Edition</h2>
            <ul>
              <li><a href="/decisioncenter" target="_blank">Decision Center Business Console</a></li>
              <li><a href="/teamserver" target="_blank">Decision Center Enterprise Console</a></li>
              <li><a href="/res" target="_blank">Decision Server Console</a></li>
              <li><a href="/DecisionService" target="_blank">Decision Server Runtime</a></li>
              <li><a href="/DecisionRunner" target="_blank">Decision Runner</a></li>
             </ul>
<%
if(System.getenv("SAMPLE") != null && System.getenv("SAMPLE").equals("true")) {
%>
            <h2 class="secondary loan-server-hidden">Sample</h2>
            <ul>
             <li class=" loan-server-hidden"><a href="/loan-server" target="_blank">Loan Server</a></li>
            </ul>
<%
}
%>
          </div>

          <div class="presentation-content right">
            <iframe src="https://www.youtube.com/embed/ccdFtyy34x8?rel=0&amp;showinfo=0&amp;" gesture="media" allow="autoplay; encrypted-media" allowfullscreen="true" class="media--iframe" frameborder="0" width="560" height="315"></iframe>
          </div>
        </div>
      </article>
    </section>

    <section id="resources">
      <article>
        <h2>Additional Resources</h2>
        <ul>
          <li><a href="https://www.ibm.com/docs/en/odm/8.11.0" target="_blank">ODM Documentation</a></li>
          <li><a href="https://www.ibm.com/community/automation/digital-business-automation/business-rules-management/" target="_blank">ODMDev Community</a></li>
          <li><a href="https://developer.ibm.com/answers/topics/ibmodm.html" target="_blank">ODMDev Forum</a></li>
        </ul>
      </article>
    </section>

    <footer>
      <article>
        <img src="images/ibm-white-logo-small.png">
          <p id="footer-copy">
              Licensed under Apache License 2.0. License information for the products installed within the image is as follows:
      <a href="https://raw.githubusercontent.com/ODMDev/odm-ondocker/master/standalone/licenses/Lic_en.txt">IBM Operational Decision Manager for Developers</a>.
  Note: The IBM Operational Decision Manager for Developers license does not permit further distribution and the terms restrict usage to a developer machine.
             </span>
          </p>
      </article>
    </footer>

    <div id="footer-extra-background"></div>
</body>

</html>
