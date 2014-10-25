/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.persistence;

import javax.persistence.*;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaDelete;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Root;
import java.util.*;

/**
 * Created by tony on 9/10/14.
 */
public class PersistenceManager <T> {

    private Class<T>         typeClass = null;
    private EntityManager    entityManager   = null;
    private CriteriaBuilder  builder         = null;

    public PersistenceManager (Class<T> aTypeClass) {

        EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory ("HR Common Persistence Unit");

        typeClass     = aTypeClass;
        entityManager = entityManagerFactory.createEntityManager();
        builder       = entityManager.getCriteriaBuilder ();
    }

    /**
     * list
     *
     * returns a list all of database objects based on T
     */
    public List<T> list () {
        return list (new HashMap<String, Object> ());
    }

    /**
     * list
     *
     * returns a list of database objects based on T for the == criteria passed in
     */
    public List<T> list (Map<String, Object> criteria) {

        List<T> list = new ArrayList<>();

        // Set the query type
        CriteriaQuery<T> select   = builder.createQuery (typeClass);
        Root<T>          entity   = select.from (typeClass);

        // If we have
        for (String attribute : criteria.keySet ()) {
            select.where (builder.equal (entity.get (attribute), criteria.get (attribute)));
        }

        EntityTransaction tx = entityManager.getTransaction ();
        try {
            tx.begin();

            Collection collection = entityManager.createQuery (select).getResultList ();

            for(Object o: collection)
                list.add (typeClass.cast (o));

            tx.commit();

        } finally {

            if (tx.isActive()) {
                tx.rollback();
            }
            entityManager.close ();
        }
        return list;
    }

    /**
     * read
     *
     * returns a single database object based on clazz for the query passed in.
     *
     *  Note: throws an Exception if the query returns more than one object.
     */
    public T read (Map<String, Object> criteria) {

        T object = null;

        List<T> list = list (criteria);

        if (list.size () > 1) {
            // Throw something
        } else {
            Iterator iterator = list.iterator ();
            if (iterator.hasNext ()) {
                object = typeClass.cast(iterator.next ());
            }
        }
        return object;
    }


    /**
     * insert
     */
    public T insert (T object) {

        EntityTransaction tx = entityManager.getTransaction ();

        try {
            tx.begin ();

            entityManager.persist (object);
            entityManager.flush();  // Flush to force the id generation

            tx.commit ();
        } finally {

            if (tx.isActive()) {
                tx.rollback();
            }
            entityManager.close ();
        }
        return object;
    }

    /**
     * update
     */
    public T update (T object) {

        T mergedObject = null;

        EntityTransaction tx = entityManager.getTransaction ();

        try {
            tx.begin ();

            mergedObject = entityManager.merge (object);
            entityManager.flush();  // Flush to force the id generation

            tx.commit ();
        } finally {

            if (tx.isActive()) {
                tx.rollback();
            }
            entityManager.close ();
        }
        return mergedObject;
    }

    /**
     * update
     */
    public int delete (Map<String, Object> criteria) {

        int rowCount = 0;

        CriteriaDelete<T> delete = builder.createCriteriaDelete (typeClass);
        Root<T>          entity  = delete.from (typeClass);

        for (String attribute : criteria.keySet ()) {
            delete.where (builder.equal (entity.get (attribute), criteria.get (attribute)));
        }

        EntityTransaction tx = entityManager.getTransaction ();
        try {
            tx.begin();

             rowCount = entityManager.createQuery (delete).executeUpdate ();

            tx.commit();

        } finally {

            if (tx.isActive()) {
                tx.rollback();
            }
            entityManager.close ();
        }

        return rowCount;
    }

}
