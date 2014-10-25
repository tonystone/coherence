/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.ws.rest;


import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.SecurityContext;
import java.io.Serializable;
import java.security.Principal;
import java.util.Date;

/**
 * Created by tony on 9/17/14.
 */
public class ApplicationSecurityContext implements javax.ws.rs.core.SecurityContext {

    public class User implements java.security.Principal{
        private String userId;          // id
        private String name;            // name
        private String emailAddress;    // email

        /**
         * Returns the name of this principal.
         *
         * @return the name of this principal.
         */
        @Override
        public String getName () {
            return null;
        }
    }

    public class Session implements Serializable {
        private static final long serialVersionUID = -7483170872690892182L;

        private String sessionId;   // id
        private String userId;      // user
        private boolean active;     // session active?
        private boolean secure;     // session secure?

        private Date createTime;    // session create time
        private Date lastAccessedTime;  // session last use time

        // getters/setters here

//        public static long getSerialVersionUID () {
//            return serialVersionUID;
//        }

        public String getSessionId () {
            return sessionId;
        }

        public void setSessionId (String sessionId) {
            this.sessionId = sessionId;
        }

        public String getUserId () {
            return userId;
        }

        public void setUserId (String userId) {
            this.userId = userId;
        }

        public boolean isActive () {
            return active;
        }

        public void setActive (boolean active) {
            this.active = active;
        }

        public boolean isSecure () {
            return secure;
        }

        public void setSecure (boolean secure) {
            this.secure = secure;
        }

        public Date getCreateTime () {
            return createTime;
        }

        public void setCreateTime (Date createTime) {
            this.createTime = createTime;
        }

        public Date getLastAccessedTime () {
            return lastAccessedTime;
        }

        public void setLastAccessedTime (Date lastAccessedTime) {
            this.lastAccessedTime = lastAccessedTime;
        }
    }

    private final User user;
    private final Session session;

    public ApplicationSecurityContext(Session session, User user) {
        this.session = session;
        this.user = user;
    }

    @Override
    public String getAuthenticationScheme() {
        return SecurityContext.BASIC_AUTH;
    }

    @Override
    public Principal getUserPrincipal() {
        return user;
    }

    @Override
    public boolean isSecure() {
        return (null != session) ? session.isSecure() : false;
    }

    @Override
    public boolean isUserInRole(String role) {

        if (null == session || !session.isActive()) {
            // Forbidden
            Response denied = Response.status(Response.Status.FORBIDDEN).entity("Permission Denied").build();
            throw new WebApplicationException(denied);
        }

        try {
            // this user has this role?
//            return user.getRoles().contains(User.Role.valueOf(role));
            return true;
        } catch (Exception e) {
        }

        return false;
    }
}
