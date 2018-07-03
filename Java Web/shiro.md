## shiro

***

[TOC]

### 概述

#### Shiro架构

1. 处理流程

   ![img](http://shiro.apache.org/assets/images/ShiroBasicArchitecture.png)

2. **Subject**: 主体，代表了当前“用户”，这个用户不一定是一个具体的人，与当前应用交互的任何东西都是**Subject**，如网络爬虫，机器人等；即一个抽象概念；所有Subject都绑定到**SecurityManager**，与**Subject**的所有交互都会委托给**SecurityManager**；可以把**Subject**认为是一个门面；**SecurityManager**才是实际的执行者；

3. **SecurityManager**: 安全管理器；即所有与安全有关的操作都会与**SecurityManager**交互；且它管理着所有**Subject**；可以看出它是**Shiro**的核心，它负责与后边介绍的其他组件进行交互，如果学习过**Spring MVC**，你可以把它看成**DispatcherServlet**前端控制器；

4. **Realm**: 域，**Shiro**通过**Realm**获取安全数据（如用户、角色、权限），就是说**SecurityManager**要验证用户身份，那么它需要从**Realm**获取相应的用户进行比较以确定用户身份是否合法；也需要从**Realm**得到用户相应的角色/权限进行验证用户是否能进行操作；

   更多**Shiro**资料参考: [Shiro官方文档](http://shiro.apache.org/reference.html) , [跟我学Shiro](http://jinnianshilongnian.iteye.com/blog/2018398)

#### 系统权限校验说明

 	Shiro权限校验是通过**过滤器**机制来实现的。通过在`web.xml`中配置Shiro过滤器，可以对指定的请求进行权限校验。Shiro的身份认证和权限校验主要是通过捕获异常来实现的，如果校验失败会抛出与失败原因对应的异常。同时支持自定义校验规则。 

### 配置与代码

#### 依赖

>```xml
><dependency>
>    <groupId>org.apache.shiro</groupId>
>    <artifactId>shiro-core</artifactId>
></dependency>
>
><dependency>
>    <groupId>org.apache.shiro</groupId>
>    <artifactId>shiro-spring</artifactId>
></dependency>
>
><dependency>
>    <groupId>org.apache.shiro</groupId>
>    <artifactId>shiro-web</artifactId>
></dependency>
>```

#### 配置过滤器

在`web.xml`中配置Filter

>```xml
><filter>
>    <filter-name>shiroFilter</filter-name>
>    <filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>
>    <init-param>
>        <param-name>targetFilterLifecycle</param-name>
>        <param-value>true</param-value>
>    </init-param>
></filter>
>    <filter-mapping>
>        <filter-name>shiroFilter</filter-name>
>        <url-pattern>/*</url-pattern>
>    </filter-mapping>
>```

#### 实现过滤器

​	针对shiroFilter，系统中有两套配置，一个是`integration-security.xml` 用于京东账号的校验，另一个是`integration-sercurity-erp` 用于erp登陆的校验, 通过在`vdc-web`工程的`pom.xml` 文件中配置`shiro.file.fix` 属性来指定使用哪一个。这里以`integration-security.xml` 为例来说明:

 1.   过滤器工厂:  `web.xml`中的**shiroFilter**对应`CustomShiroFactory-Bean` ，它继承了默认的`ShiroFilterFactoryBean`，重写了获取实例的方法，可以产生多个**Filter**实例。

 2.   过滤规则: **shiroFilter**可以针对不同的资源和链接设置不同的Filter，这些Filter对应不同的校验规则。需要在**shiroFilter**的**filterChainDefinitions**中注入不同的属性值。格式为`uri = {filter}`。需要注意的是属性值是有序的，当匹配到以个uri后就不再向下匹配了。如果一个uri有多个Filter会按照从左到右的顺序依次校验。其中使用`anon`表示任何人都可以访问。更多参数值参考[Shiro 权限管理filterChainDefinitions过滤器配置](http://blog.csdn.net/userrefister/article/details/47807075) 。系统的**filterChainDefinitions**如下:

      > ```xml
      > <property name="filterChainDefinitions">
      >    <value>
      >       /favicon.ico = anon
      >       /resources/** = anon
      >       /gateway/** = anon
      >       /vdc/item/** = anon
      >       /vdc/static/** = anon
      >       /verifyCert = anon
      >       /logout = authUserLogoutFilter
      >       /** = gatewayFilter, authFilter, mPassportauthFilter, userFilter,validUserFilter
      >    </value>
      > </property>
      > ```

      其中`AuthUserLogoutFilter` 用于登出的处理，继承`LogoutFilter` 类，重写了preHandle方法用于登出时的处理。剩下的**filter** 继承了`AccessControlFilter` 类。其中重写`isAccessAllowed` 方法用于权限的验证，重写`onAccessDenied` 方法用于验证失败后的操作。

 3.   **securityManager**:  **securityManager**直接使用了**Shiro**内置的`DefaultWebSecurityManager` 类并注入了自定义的`cacheManager`, `realm`和`sessionManager`。其中`cacheManager`主要是对Redis缓存的管理; `realm`由系统中的`AuthRealm`定义，用于获取认证数据源，主要是权限相关数据，并会清除旧的缓存；`sessionManager`对应系统中的`CustomDefaultWebSecurityManager`类，用于管理会话，在配置文件中配置了多个属性。






​	


​	