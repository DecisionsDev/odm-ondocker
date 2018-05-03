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
        <img src="images/ODM-icon.png">
        <h1>Welcome to IBM Operational Decision Manager</h1>
        <h2 class="secondary">Developer Edition</h2>
          <ul>
            <li><a href="/decisioncenter">Decision Center Business Console</a></li>
            <li><a href="/teamserver">Decision Center Enterprise Console</a></li>
            <li><a href="/res">Decision Server Console</a></li>
            <li><a href="/DecisionService">Decision Server Runtime</a></li>
            <li><a href="/DecisionRunner">Decision Runner</a></li>
          </ul>
      </article>
    </section>

    <section id="resources">
      <article>
        <h2>Additional Resources</h2>
        <ul>
          <li><a href="https://www.ibm.com/support/knowledgecenter/SSQP76_8.9.2/com.ibm.odm.icp/kc_welcome_odm_icp.html">ODM Documentation</a></li>
          <li><a href="https://developer.ibm.com/odm/">ODMDev Community</a></li>
          <li><a href="https://developer.ibm.com/answers/topics/ibmodm.html">ODMDev Forum</a></li>
        </ul>
      </article>
    </section>

    <footer>
      <article>
        <img src="images/ibm-white-logo-small.png">
        <p id="footer-copy">
          Licensed Materials &#8212 Property of IBM &copy Copyright IBM Corp.
          1997, 2018. All Rights Reserved. IBM, and the IBM logo are
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

</html>
