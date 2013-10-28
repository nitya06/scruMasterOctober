package com.neev.controller

import grails.converters.*
import groovy.json.JsonBuilder
import com.neev.domain.*
import com.neev.mainservice.ProjectInfoService
import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONObject
import com.neev.mainservice.*
import com.neev.userservice.*
import org.slf4j.Logger
import org.slf4j.LoggerFactory


class DashboardController {

    final Logger logger = LoggerFactory.getLogger(DashboardController.class)
    JsonBuilder builder = new JsonBuilder()
    def dashboardInfoService
    def commonUserValidationService
    
   /*
    *Parameters : No Parameters
    *Functionality :
    *Return :
    */
    def index()
    { 
    
    }
    
    
    /*
     *Parameters : No Parameters
     *Functionality : Call getAllAssignedTask method of DashboardInfoService
     *Return :
     */
    def getPageCount()
    {
       def json = params
       def user = commonUserValidationService.verifySessionToken(json.token)
       if(user)
       {
              def todoCount = 0
              def in_progressCount = 0
              def completedCount = 0
              
              List list = dashboardInfoService.getAllAssignedTask(user) 
              for(def i = 0 ; i <list.size() ; i++)
              {
                  if( list.status[i] == "Todo" )
                    todoCount++
                  else if ( list.status[i] == "In Progress" )
                    in_progressCount++
                  else if ( list.status[i] == "Completed" )
                     completedCount++
              }
              
              if(json.filterOption == "All")
              {
                   builder.response( "code": 200,"pageCount": list.size() )
                   render builder.toString()
              }
              else if(json.filterOption == "Todo")
              {
                   builder.response( "code": 200,"pageCount": todoCount  )
                   render builder.toString()
              }
              else if(json.filterOption == "In Progress")
              {
                   builder.response( "code": 200,"pageCount": in_progressCount  )
                   render builder.toString()
              }
              else if(json.filterOption == "Completed")
              {
                   builder.response( "code": 200,"pageCount": completedCount  )
                   render builder.toString()
              }
       }
       else
       {
           builder.response(status:"user authentication fail",code:"500")
       }   
    }
    def getAllAssignedTask()
    {  
       def json = params
       def user = commonUserValidationService.verifySessionToken(json.token)
     
       if(user)
       {
                List list1 = dashboardInfoService.getAllAssignedTask(user)
                
                def list = new ArrayList()
                def count = 0 
              
                if(json.filterOption == "Todo")
                { 
                    for (def temp = 0 ; temp<list1.size() ; temp++)
                    {
                      if(list1.status[temp] == "Todo")
                          {
                              list[count] = list1[temp]
                              count++
                          }
                    }
                }
                else if (json.filterOption == "In Progress")
                {
                    for (def temp = 0 ; temp<list1.size() ; temp++)
                    {
                      if(list1.status[temp] == "In Progress")
                          {
                              list[count] = list1[temp]
                              count++
                          }
                    }
                }
                else if (json.filterOption == "Completed")
                {
                    for (def temp = 0 ; temp<list1.size() ; temp++)
                    {
                      if(list1.status[temp] == "Completed")
                          {
                              println "kamlesh"
                              list[count] = list1[temp]
                              println "yeeeeeeelist" + list + "nitya"
                              count++
                          }
                    }
                }
                else
                {
                    list = list1
                }
             
              JSONArray id = new JSONArray()
              JSONArray name = new JSONArray()
              JSONArray description = new JSONArray()
              JSONArray status = new JSONArray()
              JSONArray projectName = new JSONArray()
             
              int startIndex = (json.firstIndex).toInteger()
              int lastIndex =  (json.lastIndex).toInteger()
             
              def i = 0 
              if( lastIndex >= list.size() )
              {
                    lastIndex = list.size()-1
              }
              
              for ( int index = startIndex ; index <= lastIndex ; index++)
              { 
                  id[i] = list.id[index]
                  name[i] = list.name[index]
                  description[i] = list.description[index]
                  status[i] = list.status[index]
                  projectName[i] = list.project[index].name
                  i++
              }
              builder.response("code": 200,"id": id,"name": name,"description":description ,"status":status ,"projectName":projectName)
              render builder.toString()
       }
       else
       {
           builder.response(status:"user authentication fail",code:"500")
       }   
    }
    
    /*
     *Parameters : No Parameters
     *Functionality : Call getAllCreatedProject method of DashboardInfoService
     *Return :
    */
    def getAllCreatedProject()
    {
       println "getAllCreated Project"
        def json = params
        def user = commonUserValidationService.verifySessionToken(json.token)
        if(user)
        {
            List list = dashboardInfoService.getAllCreatedProject(user) 
            JSONArray id = new JSONArray(list.id)
            JSONArray name = new JSONArray(list.name)
            JSONArray description = new JSONArray(list.description)
            JSONArray status = new JSONArray(list.status)
            JSONArray dateCreated = new JSONArray(list.dateCreated.toString())
            JSONArray lastUpdated = new JSONArray(list.lastUpdated.toString())
            JSONArray endDate = new JSONArray(list.endDate.toString())
            
           
            builder.response("code": 200,"id": id,"name": name,"status":status ,"description":description,"dateCreated":dateCreated,"endDate":endDate,"lastUpdated":lastUpdated)
            render builder.toString()
        }
        else
        {
            builder.response(status:"user authentication fail",code:"500")
        }   
    }
    
    
    /*
    *Parameters : No Parameters
    *Functionality : Call updateAssignedTask method of DashboardInfoService
    *Return :
    */
    def updateAssignedTask()
    {
        def json = request.JSON
        def user = commonUserValidationService.verifySessionToken(json.token)
        if(user)
        {       
            if( dashboardInfoService.updateAssignedTask(json) )
            {
                builder.response(status:"user authentication success and Data updated",code:"200")
                render builder.toString()
            }
        }
        else
        {
            builder.response(status:"user authentication fail",code:"500")
            render builder.toString()
        }
    }
    
    /*
     *Parameters : No Parameters
     *Functionality : Call getTaskStatus method of DashboardInfoService
     *Return :
    */
    def getTaskStatus()
    {
        def json = params
        def user = commonUserValidationService.verifySessionToken(json.token)
        if(user)
        {
            def status = dashboardInfoService.getTaskStatus(json)              
            builder.response("code": 200,"taskStatus":status)
            render builder.toString()
        }
        else
        {
            builder.response(status:"user authentication fail",code:"500")      
        }
    }
}