package com.neev.mainservice

import grails.transaction.Transactional
import com.neev.domain.*

import java.util.*
import org.slf4j.Logger
import org.slf4j.LoggerFactory

@Transactional
class TaskInfoService 
{
    final Logger logger = LoggerFactory.getLogger(TaskInfoService.class)

   /*
    *Parameters :
    *Functionality :
    *Return :
    */
    def add(def json , def user)
    {
        logger.info("Enterd into add method of TaskInfoService")
        def newTask = new Task()
        newTask.name=json.name
        newTask.status=json.status
        newTask.description=json.description
        def project = Project.findById(json.project_id)
        newTask.project = project
       
            def sprint = Sprint.findById(json.sid)
            newTask.sprint = sprint
      
       
            def userStory = UserStory.findByName(json.userStory)
            newTask.userStory = userStory
       
            def adduser = User.findByEmail(json.user)       
            newTask.user = adduser
        
        
        try
        {
            if(newTask.save())
            {
                logger.info("Returning save from add method of TaskInfoService")
                return "save"
            }
            else
            {
                logger.info("Returning notSave from add method of TaskInfoService")
                return "notSave"
            } 
        }
        catch(Exception e)
        {
            println e
            logger.info("Exception in add method of TaskInfoService")
        }
   }

    /*
     *Parameters :
     *Functionality :
     *Return :
     */
    def update(def json)
    {     
        logger.info("Enterd into update method of TaskInfoService")
        def newTask = Task.findById(json.tid)
        newTask.name=json.name
        def sprint = newTask.sprint
       
        if(json.userStory != "undefined" )
        {
            def userStory = UserStory.findByName(json.userStory)
            newTask.userStory = userStory
        }
        if(json.user != "undefined")
        {
            def adduser = User.findByEmail(json.user)       
            newTask.user = adduser
        }
        newTask.description=json.description  
        
             
        try
        {
            if(newTask.save())
            {
                logger.info("Returning update from update method of TaskInfoService")
                return "update"
            }
            else
            {
                logger.info("Returning notUpdate from update method of TaskInfoService")
                return "notUpdate"
            }
        }
        catch(Exception e)
        {
            println e
            logger.info("Exception in update method of TaskInfoService")
        }
    }
    
    /*
     *Parameters :
     *Functionality :
     *Return :
     */
    def get(def json)
    {  
        logger.info("Enterd into get method of TaskInfoService")
        def sprint = Sprint.findById(json.sid)
        List list = Task.findAllBySprint(sprint)
        logger.info("Returning list of tasks from get method of TaskInfoService")
        return list
    }
    
    /*
     *Parameters :
     *Functionality :
     *Return :
     */
    boolean isHasSprint(def user,def json)
    {
        logger.info("Enterd into isHasSprint method of TaskInfoService")
        def sprint = Sprint.findById(json.sid)  //To be Verified
        if(sprint?.userId==user.id)
        {
            logger.info("Returning true from isHasSprint method of TaskInfoService")
            return true
        }
        logger.info("Returning true from isHasSprint method of TaskInfoService")
        return false
    }
    
    /*
     *Parameters :
     *Functionality :
     *Return :
     */
    boolean isUserStoryAvailableForProject(def json)
    {   
        logger.info("Enterd into isUserStoryAvailableForProject method of TaskInfoService")
        def userStory = UserStory.findByName(json.userStory)  
        def sprint = Sprint.findById(json.sid)
        def release = sprint.release
        def release1 = Release1.findById(release.id)
        if(release1.project ==  userStory.projects )
        {
            logger.info("Returning true from isUserStoryAvailableForProject method of TaskInfoService")
            return true
        }
        logger.info("Returning false from isUserStoryAvailableForProject method of TaskInfoService")
        return false        
    }
    
    /*
     *Parameters :
     *Functionality :
     *Return :
     */
    boolean isHasTask(def user,def json)
    {
        logger.info("Enterd into isHasTask method of TaskInfoService")
        def task  = Task.findById(json.tid)
        def sprint1 = task.sprint
        def sprint = Sprint.findById(sprint1.id)
        if(sprint?.userId == user.id)
        {
            logger.info("Returning true from isHasTask method of TaskInfoService")
            return true
        }
        logger.info("Returning false from isHasTask method of TaskInfoService")
        return false
    }
    
    
    def addTaskFromReleaseBoard(def json , def user)
    {
        logger.info("Enterd into add method of TaskInfoService")
        def newTask = new Task()
        newTask.name=json.name
        newTask.status=json.status
        newTask.description=json.description
        
        def project = Project.findById(json.project_id)
        newTask.project = project

           def sprint = Sprint.findByName(json.sprint_name)
           if(sprint)
           newTask.sprint = sprint
       
           def userStory = UserStory.findByName(json.userStory)
           if(userStory)
           newTask.userStory = userStory
       
           def adduser = User.findByEmail(json.user)  
           if(adduser)
           newTask.user = adduser
       
        try
        {
            if(newTask.save())
            {
                 logger.info("Returning save from add method of TaskInfoService")
                 return "save"
            }
            else
            {
                        logger.info("Returning notSave from add method of TaskInfoService")
                        return "notSave"
            }        
        }
        catch(Exception e)
        {
            println e
            logger.info("Exception in add method of TaskInfoService")
        }
   }
   
   def getPageCountForAllTask(def json)
   {
       def project = Project.findById(json.project_id)
       List tasks = Task.findAllByProject(project)
       return tasks
   }
   def fetchTaskInfo(def json)
   {
       def task = Task.findById(json.task_id)
       return task
   }
   
    def updateTaskFromAllTask(def json)
    {
        logger.info("Enterd into update method of TaskInfoService")
      
        def newTask = Task.findById(json.task_id)
        newTask.name=json.name
        newTask.description=json.description  
        println "ooooooooooooooojiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii" + json.sprint_name
        
        if(json.sprint_name != "undefined" )
        {
            def sprint = Sprint.findByName(json.sprint_name)
            newTask.sprint = sprint
        }
       
        if(json.userStory != "undefined" )
        {
            def userStory = UserStory.findByName(json.userStory)
            newTask.userStory = userStory
        }
        if(json.user != "undefined")
        {
            def adduser = User.findByEmail(json.user)       
            newTask.user = adduser
        }
      
        try
        {
            if(newTask.save())
            {
                logger.info("Returning update from update method of TaskInfoService")
                return "update"
            }
            else
            {
                logger.info("Returning notUpdate from update method of TaskInfoService")
                return "notUpdate"
            }
        }
        catch(Exception e)
        {
            println e
            logger.info("Exception in update method of TaskInfoService")
        }
    }
}