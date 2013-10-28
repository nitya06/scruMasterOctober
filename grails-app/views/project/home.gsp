<!DOCTYPE html>
<html data-ng-app="scruMaster">
  <head>
    <title>ScruMaster</title>
    <!-- for model -->
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
    <script src="http://code.jquery.com/jquery-1.9.1.js"></script>
    <!-- bootstrap css for glyphicons --->
    <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css">
    <!-- require to perform action on bootstrap on control ---->
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>
    <!-- css for header -->
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'style.css')}" type="text/css">
    <!-- it is for common div box -->
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'commonDivStyle.css')}" type="text/css">
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/angularjs/1.0.8/angular.min.js"></script>
    <script type="text/javascript" src="${resource(dir: 'js', file: 'angular-flash.js')}"></script>
  </head>

  <body>

    <!-- for user authentication-->
    <input type="hidden" id="token" value="${params.sessionToken}"/> 


    <!-- Header Part Start here-->
    <div class="wrapper"  style="margin-top:0%;margin-left:0%;background: #3B5998">
      <div class="container pull-left" ><label class="newStyle">Hi ${params.username}</label></div>
      <div class="container pull-left" ><h3 style="color:white"></h3></div>  
      <div class="container pull-right" style="margin-right:-1.2%; background-color:  #3B5998">
        <ul class="menu">

          <li><a href="#/dashboardFetch"><button type="button" class="btn btn-link" style="color:#FFFFFF">My Dashboard</button></a></li>
          <li><a href="#/myAccount/${params.username}/${params.email}"><button type="button" class="btn btn-link" style="color:#FFFFFF;">My Account</button></a></li>
          <li><a href="http://10.132.160.215:8080/iceScrum/users/signOut?token=${params.sessionToken}"><button type="button" class="btn btn-link" style="color:#FFFFFF;"><i class="icon-white icon-off">Log Out</i></button></a></li>
        </ul>
      </div>
    </div> 
    <!-- Header Part End here-->


    <br><br><br>

    <!-- Changing DIV -->    

    <div ng-view></div>
    <!-- Route configuration -->

    <script> 
       var scrumApp = angular.module("scruMaster", ['angular-flash.flash-alert-directive']);          
       scrumApp.config(function ($routeProvider){
              $routeProvider
                
              // view and controller mapping for updateAccount---------------------------
              .when('/myAccount/:username/:email',
              {   
                  controller: 'myAccountController',
                  templateUrl: "${resource(dir: 'gspPages', file: 'myAccount.html')}"
              })
                   
              // view and controller mapping for Dashboard----------------------------------
              .when('/dashboardFetch',
              {   
                  controller: 'dashboardController',
                  templateUrl: "${resource(dir: 'gspPages', file: 'dashboardFetch.html')}"
              })
                
              // view and controller mapping for releaseBoard----------------------------------  
              .when('/releaseBoard/:projectId/:projectName/:projectStartDate/:projectEndDate',
              {   
                  controller: 'releaseBoardController',
                  templateUrl: "${resource(dir: 'gspPages', file: 'releaseBoard.html')}"
              })
              
              // view and controller mapping for sprintBoard----------------------------------  
              .when('/sprintBoard/:releaseId/:releaseName/:projectId/:projectName/:releaseStartDate/:releaseEndDate',
              {   
                  controller: 'sprintBoardController',
                  templateUrl: "${resource(dir: 'gspPages', file: 'sprintBoard.html')}"
              })
              
              // view and controller mapping for taskBoard----------------------------------  
              .when('/taskBoard/:sprintId/:sprintName/:releaseId/:releaseName/:projectId/:projectName/:sprintStartDate/:sprintEndDate',
              {   
                  controller: 'taskBoardController',
                  templateUrl: "${resource(dir: 'gspPages', file: 'taskBoard.html')}"
              })
              
              // view and controller mapping for allTaskBoard----------------------------------  
              .when('/allTaskBoard/:projectId',
              {   
                  controller: 'allTaskBoardController',
                  templateUrl: "${resource(dir: 'gspPages', file: 'allTaskBoard.html')}"
              })
                               
              // default page load 
              .otherwise( {redirectTo: '/dashboardFetch'} );
          }
      );
 
  
            scrumApp.filter('startFrom', function() {
                     return function(input, start) {
                              start = +start; 
                              return input.slice(start);
                     }
});


          // angular js controller----------------------------------------------------------->

          //myAccount controller for userProfile
          function myAccountController($routeParams,$scope,$http,flash){
              
               var sessionToken = document.getElementById("token")
               this.params = $routeParams;
               $scope.username = this.params.username
               $scope.email = this.params.email
               $scope.changepassword=function(){
                       var temp = '{token='+sessionToken.value+',oldpassword='+$scope.old+',newpassword='+$scope.news+'}'
                
                     $http.post("http://10.132.160.215:8080/iceScrum/updateProfile",temp).success(function(data,status,headers,config){
                                 if(data.response.code == 200)
                                    {
                                      location.reload()
                                    }
                                    else
                                      flash.success=data.response.status
                      }).error(function(data,status,headers,config){
                                      alert("error")
                      });      
                }
          }
            
          //dashboard controller for fetch and save and update the data on server
          function dashboardController($location,$routeParams,$scope,$http,flash){
                 
               var sessionToken = document.getElementById("token")
               $scope.selectedFilter="All"

               //pagination
               
               $scope.getPageCount = function(filterOption) {
                    $scope.selectedFilterVar = filterOption
                     var paginationArray = new Array();
                     var countpaginationArray = 1
                     
                     $http.get("http://10.132.160.215:8080/iceScrum/getPageCount", {
                                        params: { token: sessionToken.value , filterOption:filterOption }
                      }).success(function(data,status,headers,config){
                               
                                    
                             if( data.response.code == 200)
                               {   
                                   for (var i = data.response.pageCount ; i>0 ; i=i-4)
                                   {
                                     var temp = { "count": countpaginationArray ,"startIndex":(countpaginationArray-1)*4,"endIndex":((countpaginationArray-1)*4)+3};
                                     paginationArray[countpaginationArray] = temp
                                     countpaginationArray++
                                   }
                                   $scope.paginationArray = paginationArray
                                   $scope.fetchAssignedTasks(filterOption,0,3)
                               }
                      }).error(function(data,status,headers,config){
                                      alert("fetching error in pagination")
                      });
                   }
                 
                
               // fetch all the tasks which are assigned to this perticular user ----------
               $scope.fetchAssignedTasks = function(filterOption,firstIndex,lastIndex) {
                    
                     var newArrayColor1 = new Array();
                     var newArrayColor2 = new Array();
                     var newArrayColor3 = new Array();
                     
                      var count1 = 0
                      var count2 = 0
                      var count3 = 0
                     $http.get("http://10.132.160.215:8080/iceScrum/dashboardGetAssignTask", {
                                        params: { token: sessionToken.value , firstIndex: firstIndex , lastIndex:lastIndex , filterOption:filterOption}
                      }).success(function(data,status,headers,config){
                               
                                    
                             if( data.response.code == 200)
                               {   
                                   for(var i=0 ; i < data.response.id.length ; i++)
                                   {
                                      if( data.response.status[i] == "Todo")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"desc": data.response.description[i],"status":data.response.status[i],"projectName":data.response.projectName[i]};
                                          newArrayColor1[count1++]= temp
                                       }
                                       else if( data.response.status[i] == "In Progress")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"desc": data.response.description[i],"status":data.response.status[i],"projectName":data.response.projectName[i]};
                                          newArrayColor2[count2++]= temp
                                       }
                                       else if( data.response.status[i] == "Completed")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"desc": data.response.description[i],"status":data.response.status[i],"projectName":data.response.projectName[i]};
                                          newArrayColor3[count3++]= temp
                                       }           
                                   }
                                   $scope.ArrayColor1 = newArrayColor1
                                   $scope.ArrayColor2 = newArrayColor2
                                   $scope.ArrayColor3 = newArrayColor3
                               }
                      }).error(function(data,status,headers,config){
                                      alert("fetching error in assigned task list")
                      });
                   }
                    
                 // save the project for this user who is manager of this project --------------
                   $scope.projectStatus = "Todo"
                   var todayDate  = new Date()
                   var str = todayDate.getFullYear() +"-"+(todayDate.getMonth()+1)+"-"+todayDate.getDate()
                   $scope.todayDate = str
                   $scope.saveProject = function() {
                   
                       
                        var desc= "'"+$scope.projectDescription+"'"


                           var temp = '{token='+sessionToken.value+',name='+$scope.projectName+',description='+desc+',status='+$scope.projectStatus+',startdate='+$scope.projectStartDate+',enddate='+$scope.projectEndDate+'}'

                          $http.post("http://10.132.160.215:8080/iceScrum/project",temp).success(function(data,status,headers,config){


                                       if(data.response.code == 200)
                                         {
                                           location.reload()
                                         }
                                         else
                                           flash.success=data.response.status

                           }).error(function(data,status,headers,config){
                                           alert("Data is not valid !!!!!!!")
                           });
                        
                } 
    
                         
   
               
                  
                // first fetch the data for update the task which are assigned to this perticular user   --------------------------------------------------  
                  
                $scope.FetchDataForUpdateTask = function(task_id,name,desc,startDate,endDate) {         
                  var taskStatusArray = new Array();
                  $scope.taskId = task_id
                  $scope.taskName = name
                  $scope.taskDescription = desc
                  $scope.taskStartDate = startDate
                  $scope.taskEndDate = endDate
                  //check the task status ----------------------------------------------
                   $http.get("http://10.132.160.215:8080/iceScrum/dashboardGetTaskStatus", {
                                        params: { token: sessionToken.value , tid: task_id }
                      }).success(function(data,status,headers,config){
                               
                                       
                             if( data.response.code == 200)
                               {
                                     
                                    if(data.response.taskStatus == "Todo")
                                    {
                                      $scope.taskStatus = "Todo"
                                      taskStatusArray[0] = "In Progress"
                                      taskStatusArray[1] = "Todo"
                                        
                                    }
                                    else if(data.response.taskStatus == "In Progress")
                                    {
                                      $scope.taskStatus = "In Progress"
                                      taskStatusArray[0] = "Completed"
                                      taskStatusArray[1] = "In Progress"
                                        
                                    }
                                    else if(data.response.taskStatus == "Completed")
                                    {
                                      $scope.taskStatus = "Completed"
                                      taskStatusArray[0] = "Completed"
                                    }
                                   
                                 $scope.myTaskStatusCheckArray = taskStatusArray
                               }
                    
            
                      }).error(function(data,status,headers,config){
                                      alert("fetching error for task status")
                      });
          
          
                } 
                  
                 // update the task which are assigned to this user who is logg on      -------------------------
                $scope.updateTask = function() {
           
                   var temp = '{token='+sessionToken.value+',task_id='+$scope.taskId+',status='+$scope.taskStatus+',enddate='+$scope.taskEndDate+'}'

                     $http.put("http://10.132.160.215:8080/iceScrum/dashboardUpdateAssignedTask",temp).success(function(data,status,headers,config){
                                    if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                    else
                                      alert(data.response.status)
                      }).error(function(data,status,headers,config){
                                      alert("Error")
                      });
                        
                } 
                
                
                 // reserved function for project list which is common for all pages 
       
                   $scope.fetchCreatedProject = function() {
                    
                      var projectsName1 = new Array();
                     
                          $scope.currentPage = 0;
                     $scope.pageSize = 5;
                      var count4 = 0
                     
                     
                     $http.get("http://10.132.160.215:8080/iceScrum/GetProjectList", {
                                        params: { token: sessionToken.value }
                      }).success(function(data,status,headers,config){
                              
                                       
                             if( data.response.code == 200)
                               {
                                     $scope.length=data.response.id.length
                                
                               $scope.numberOfPages=Math.ceil($scope.length/$scope.pageSize)
                                   for(var i=0 ; i < data.response.id.length ; i++)
                                   {
                                      if( data.response.status[i] == "Todo")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#CCE5FF"};
                                          projectsName1[count4++]= temp
                                            
                                       }
                                       else if( data.response.status[i] == "In Progress")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#FFFF99"};
                                          projectsName1[count4++]= temp
                                       }
                                       else if( data.response.status[i] == "Completed")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#CCFF99"};
                                          projectsName1[count4++]= temp
                                       }
                                         
                                               
                                   }
                                   $scope.ArrayProject1 = projectsName1
                               }
             
            
                      }).error(function(data,status,headers,config){
                                      alert("fetching error in project list")
                      });

                           
                   }         
               
               
                // first fetch the data for update the project   --------------------------------------------------  
                $scope.FetchDataForUpdateProject = function(project_id,name,desc,startDate,endDate) {
                
                  $scope.projectId = project_id
                  $scope.projectName = name
                  $scope.projectDescription = desc
                  $scope.projectStartDate = startDate
                  $scope.projectEndDate = endDate
          
                } 
              
                // update the project which are created by this perticular user --------------------------
                $scope.updateProject = function() {
                      
                     var desc= "'"+$scope.projectDescription+"'"
                     var temp = '{token='+sessionToken.value+',project_id='+$scope.projectId+',name='+$scope.projectName+',description='+desc+',startdate='+$scope.projectStartDate+',enddate='+$scope.projectEndDate+'}'
                        
                       
                     $http.put("http://10.132.160.215:8080/iceScrum/project",temp).success(function(data,status,headers,config){
                         
                                   if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                    else
                                      alert(data.response.status)
                                          
                            }).error(function(data,status,headers,config){
                                            alert("Error"+data)
                            });
                        
                } 
                //end reserved function
                  
     
              }
    
              // releaseBoard controller ------------------------------------------------
              function releaseBoardController($location,$routeParams,$scope,$http,flash){
                 
               var sessionToken = document.getElementById("token")
             
               this.params = $routeParams;
               var project_id = this.params.projectId 
               $scope.startdate = this.params.projectStartDate
               $scope.enddate = this.params.projectEndDate
               $scope.projectNAME =this.params.projectName
               $scope.projectID = project_id
  
               $scope.selectedFilter="All"
 
               // page count for release board 
               $scope.getPageCount = function(filterOption) {
                    $scope.selectedFilterVar = filterOption
                     var paginationArray = new Array();
                     var countpaginationArray = 1
                     
                     $http.get("http://10.132.160.215:8080/iceScrum/getPageCountForRelease", {
                                        params: { token: sessionToken.value , pid: project_id , filterOption:filterOption }
                      }).success(function(data,status,headers,config){
                               
                                    
                             if( data.response.code == 200)
                               {   
                                   for (var i = data.response.pageCount ; i>0 ; i=i-4)
                                   {
                                     var temp = { "count": countpaginationArray ,"startIndex":(countpaginationArray-1)*4,"endIndex":((countpaginationArray-1)*4)+3};
                                     paginationArray[countpaginationArray] = temp
                                     countpaginationArray++
                                   }
                                      
                                      
                                   $scope.paginationArray = paginationArray
                                   $scope.fetchCreatedReleases(filterOption,0,3)
                               }
             
            
                      }).error(function(data,status,headers,config){
                                      alert("fetching error in eeeee")
                      });

                   }
   
               // fetch all the releases which are created by this perticular user(on Borad) ----------
               $scope.fetchCreatedReleases = function(filterOption,firstIndex,lastIndex) {
                       
                        var newArrayColor1 = new Array();
                        var newArrayColor2 = new Array();
                        var newArrayColor3 = new Array();

                        var count1 = 0
                        var count2 = 0
                        var count3 = 0
                          $http.get("http://10.132.160.215:8080/iceScrum/release", {
                                             params: { token: sessionToken.value , pid: project_id , firstIndex:firstIndex , lastIndex:lastIndex ,filterOption:filterOption }
                         }).success(function(data,status,headers,config){

                               if( data.response.code == 200)
                               {
                                   
                                     
                                   for(var i=0 ; i < data.response.id.length ; i++)
                                   {
                                      if( data.response.status[i] == "Todo")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"desc": data.response.description[i],"status":data.response.status[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i]};
                                          newArrayColor1[count1++]= temp
                                       }
                                       else if( data.response.status[i] == "In Progress")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"desc": data.response.description[i],"status":data.response.status[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i]};
                                          newArrayColor2[count2++]= temp
                                       }
                                       else if( data.response.status[i] == "Completed")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"desc": data.response.description[i],"status":data.response.status[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i]};
                                          newArrayColor3[count3++]= temp
                                       }
                                               
                                   }
                                     
                                   $scope.ArrayColor1 = newArrayColor1
                                   $scope.ArrayColor2 = newArrayColor2
                                   $scope.ArrayColor3 = newArrayColor3
                                   
                               }
                                  
             
                          }).error(function(data,status,headers,config){
                                           alert("fetching error in release")

                          });

                       
                   }
   
                  
 
                 // fetch all the userStory for perticular project ( in release creation model and release updation )
                 $scope.fetchUserStorysForProject= function(){
                  
                         var UserStoryforProject = new Array(); 
                         var countUserStoryforProject = 0
                         
                         $http.get("http://10.132.160.215:8080/iceScrum/fetchUserStorysForProject", {
                                             params: { token: sessionToken.value , project_id: project_id}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               for(var i=0 ; i < data.response.id.length ; i++)
                                               {
                                                       
                                                         var temp = {"id": data.response.id[i] , "name":data.response.name[i],"desc": data.response.description[i]};
                                                         UserStoryforProject[countUserStoryforProject++]= temp
                                                       
                                               }
                                                 
                                               $scope.UserStoryforProject = UserStoryforProject
                                            
                                                   
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          });

                     } 
                 
                    
                 
                    
                   // save the release for this user who is manager of this project --------------
                   $scope.releaseStatus = "Todo"
                   $scope.saveRelease = function() {
                        var desc= "'"+$scope.releaseDescription+"'"
                     var userStoryArrayString = "0-";
                     for(var i=0 ; i<$scope.selectedUserStorys.length ; i++)
                     { 
                         userStoryArrayString += $scope.selectedUserStorys[i].id
                         if (i !=$scope.selectedUserStorys.length-1){
                          userStoryArrayString += "-";
                         }
                     }
                     var temp = '{token='+sessionToken.value+',pid='+project_id+',name='+$scope.releaseName+',descripition='+desc+',status='+$scope.releaseStatus+',startdate='+$scope.releaseStartDate+',enddate='+$scope.releaseEndDate+',userStorys='+userStoryArrayString+'}'

                     $http.post("http://10.132.160.215:8080/iceScrum/release",temp).success(function(data,status,headers,config){
                                  if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                    else if (data.response.code == 300 || data.response.code == 600 )
                                           flash.success=data.response.status
                                  // alert(data.response.status)
                      }).error(function(data,status,headers,config){
                                      alert("Data is not valid !!!!!!!")
                      });
                        
                }
                                 
                  
                 // first fetch the data for update the release   --------------------------------------------------  
                $scope.FetchDataForUpdateRelease = function(release_id,name,desc,startDate,endDate) {
                    
                  $scope.releaseId = release_id
                  $scope.releaseName = name
                  $scope.releaseDescription = desc
                  $scope.releaseStartDate = startDate
                  $scope.releaseEndDate = endDate
          
                } 
   
                // update the release which are created by this perticular user      --------------------------
                 $scope.updateRelease = function() {
                     var desc= "'"+$scope.releaseDescription+"'"
                     var userStoryArrayString = "0-";
                     for(var i=0 ; i<$scope.selectedUserStorys.length ; i++)
                     { 
                         userStoryArrayString += $scope.selectedUserStorys[i].id
                         if (i !=$scope.selectedUserStorys.length-1){
                          userStoryArrayString += "-";
                         }
                     }
                       
                    
                     var temp = '{token='+sessionToken.value+',rid='+$scope.releaseId+',name='+$scope.releaseName+',description='+desc+',startdate='+$scope.releaseStartDate+',enddate='+$scope.releaseEndDate+',userStorys='+userStoryArrayString+'}'


                     $http.put("http://10.132.160.215:8080/iceScrum/release",temp).success(function(data,status,headers,config){
                                  if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                    
                                      else if(data.response.code == 300)
                                    flash.success=data.response.status
                      }).error(function(data,status,headers,config){
                                      alert("Error")
                      });
                        
                }   
                   
                
                 // fetch all releases for perticular project(in userStory Model and create task model ) -----------
                 var releasesArray = new Array();
                 var countRelease = 0
                   
                 $scope.fetchReleasesForSpecificProject= function(){
                         
                           
                         $http.get("http://10.132.160.215:8080/iceScrum/ReleasesForSpecificProject", {
                                             params: { token: sessionToken.value , project_id: project_id}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               for(var i=0 ; i < data.response.id.length ; i++)
                                               {
                                                       

                                                         var temp = {"id": data.response.id[i] , "name":data.response.name[i]};
                                                         releasesArray[countRelease++]= temp

                                                        
                                               }
                                                 
                                               $scope.availableRelease = releasesArray
                                                
                                                   
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          });
                            
                       

                     } 
                       
                       
                //fetch all sprints for perticular release -----------(in userstory model and create task model )
                   
                 $scope.fetchSprintsForSpecificRelease= function(){
                          var release_name = $scope.selectedRelease
                            
                          var sprintArray = new Array();
                          var countSprint = 0
                         
                          $http.get("http://10.132.160.215:8080/iceScrum/SprintsForSpecificRelease", {
                                             params: { token: sessionToken.value , release_name: release_name}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               for(var i=0 ; i < data.response.id.length ; i++)
                                               {
                                                         var temp = {"id": data.response.id[i] , "name":data.response.name[i]};
                                                         sprintArray[countSprint++]= temp
                                                    
                                               }
                                                 
                                               $scope.availableSprint = sprintArray
                                               countSprint = 0
                                                
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          });
                          
                      
                  }
                   
                   
                   
                    // save the userStory for specific release and project
                     $scope.saveUserStory = function() {
                      
                     var desc= "'"+$scope.userStoryDescription+"'"
                     var temp = '{token='+sessionToken.value+',project_id='+project_id+',release_name='+$scope.selectedRelease+',sprint_name='+$scope.selectedSprint+',name='+$scope.userStoryName+',description='+desc+'}'

                     $http.post("http://10.132.160.215:8080/iceScrum/UserStoryForSpecificProject",temp).success(function(data,status,headers,config){
                                    if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                    else
                                      alert(data.response.status)
                      }).error(function(data,status,headers,config){
                                      alert("Error")
                      });
                        
                  }
                    
                   // first fetch the data for update the userStory   --------------------------------------------------  
                  $scope.FetchDataForUpdateUserStory = function(userStory_id,name,desc) {

                    $scope.userStoryId = userStory_id
                    $scope.userStoryName = name
                    $scope.userStoryDescription = desc

                  } 
                  
                  // update the userStory --------------------------
                   
                  $scope.updateUserStory = function() {
                      
                  var desc= "'"+$scope.userStoryDescription+"'"
                     var temp = '{token='+sessionToken.value+',userStory_id='+$scope.userStoryId+',name='+$scope.userStoryName+',description='+desc+',release_name='+$scope.selectedRelease+',sprint_name='+$scope.selectedSprint+'}'

                     $http.put("http://10.132.160.215:8080/iceScrum/updateUserStory",temp).success(function(data,status,headers,config){
                                  if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                    
                      }).error(function(data,status,headers,config){
                                      alert("client side error !!!!!!!")
                      });
                        
                }      
                    
                    
                    
                    // page count for user story in releaseboard 
                    $scope.getPageCountForUserStory = function() {
                    
                     var paginationArray = new Array();
                     var countpaginationArray = 1
                     
                     $http.get("http://10.132.160.215:8080/iceScrum/getPageCountForUserStory", {
                                        params: { token: sessionToken.value , project_id: project_id }
                      }).success(function(data,status,headers,config){
                               
                                   
                             if( data.response.code == 200)
                               {   
                                   for (var i = data.response.pageCount ; i>0 ; i=i-4)
                                   {
                                     var temp = { "count": countpaginationArray ,"startIndex":(countpaginationArray-1)*4,"endIndex":((countpaginationArray-1)*4)+3};
                                     paginationArray[countpaginationArray] = temp
                                     countpaginationArray++
                                   }
                                      
                                      
                                   $scope.paginationArrayForUserStory = paginationArray
                                   
                               }
             
            
                      }).error(function(data,status,headers,config){
                                      alert("fetching error in userstory")
                      });

                   }
    
                   
                  // fetch the userStory according to specific release and project (on the board)
               
                  $scope.fetchUserStorysForSpecificProject= function(firstIndex , lastIndex){
                          
                              
                         var projectUserStorys = new Array();
                         var counting = 0
                    
                          
                         $http.get("http://10.132.160.215:8080/iceScrum/AllUserStoryForSpecificProject", {
                                             params: { token: sessionToken.value , project_id: project_id ,firstIndex:firstIndex,lastIndex:lastIndex}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               for(var i=0 ; i < data.response.id.length ; i++)
                                               {
                                                        
                                                         var temp = {"id": data.response.id[i] , "name":data.response.name[i],"desc": data.response.description[i]};
                                                         projectUserStorys[counting++]= temp
                                                        
                                               }
                                                 
                                               $scope.projectUserStoryss = projectUserStorys
                                                 
                                                   
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)
                                            

                          });

                     }
    
                 //fetch all userStories for perticular sprint and sprint date also -----------(in task model)
                   
                 $scope.fetchUserStoriesForSpecificSprint= function(){
                          var sprint_name = $scope.selectedSprint
                            
                          var userStoriesArray = new Array();
                          var countUserStories = 0
                         
                          $http.get("http://10.132.160.215:8080/iceScrum/fetchUserStoriesForSpecificSprint", {
                                             params: { token: sessionToken.value , sprint_name: sprint_name}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               for(var i=0 ; i < data.response.id.length ; i++)
                                               {
                                                         var temp = {"id": data.response.id[i] , "name":data.response.name[i]};
                                                         userStoriesArray[countUserStories++]= temp
                                                    
                                               }
                                                 
                                               $scope.availableUserStories = userStoriesArray
                                               countUserStories = 0
                                                  
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          });
                          
                           $http.get("http://10.132.160.215:8080/iceScrum/fetchDatesForParticularSprint", {
                                             params: { token: sessionToken.value , sprint_name: sprint_name}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               $scope.sDate = data.response.startDate
                                               $scope.eDate = data.response.endDate
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          }); 
                  }
 
                // fetch all registered users for assign the task      
                $scope.fetchUsers= function(){
                           
                         $http.get("http://10.132.160.215:8080/iceScrum/fetchUsersForTask", {
                                             params: { token: sessionToken.value}
                         }).success(function(data,status,headers,config){
                                         
                                      $scope.usersArray = data
                                       
                          }).error(function(data,status,headers,config){
                             
                                           alert("Fetching Error")

                          });

                  }  
                  
                  
                 // save the task data on the server
                $scope.taskStatus = "Todo"
                $scope.saveTask = function() {
                      
                    var desc= "'"+$scope.taskDescription+"'"
                   var temp = '{token='+sessionToken.value+',project_id='+project_id+',sprint_name='+$scope.selectedSprint+',name='+$scope.taskName+',description='+desc+',status='+$scope.taskStatus+',startdate='+$scope.taskStartDate+',enddate='+$scope.taskEndDate+',userStory='+$scope.taskUserStories+',user='+$scope.taskUsers+'}'

                     $http.post("http://10.132.160.215:8080/iceScrum/saveTaskFromReleaseBoard",temp).success(function(data,status,headers,config){
                                    if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                   
                                    else if( data.response.code == 300 || data.response.code == 600 || data.response.code == 800 )
                                      flash.success=data.response.status
                      }).error(function(data,status,headers,config){
                                      alert("Error")
                      });
                        
                } 
                
                
                 // reserved function for project list which is common for all pages 
       
                   $scope.fetchCreatedProject = function() {
                    
                      var projectsName1 = new Array();
                      var projectsName2 = new Array();
                      var projectsName3 = new Array();
                     $scope.currentPage = 0;
                     $scope.pageSize = 5;
                      var count4 = 0
                      var count5 = 0
                      var count6 = 0
                     
                     $http.get("http://10.132.160.215:8080/iceScrum/GetProjectList", {
                                        params: { token: sessionToken.value }
                      }).success(function(data,status,headers,config){
                              
                                       
                             if( data.response.code == 200)
                               {
                                     $scope.length=data.response.id.length
                                
                               $scope.numberOfPages=Math.ceil($scope.length/$scope.pageSize)
                                   for(var i=0 ; i < data.response.id.length ; i++)
                                   {
                                      if( data.response.status[i] == "Todo")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#CCE5FF"};
                                          projectsName1[count4++]= temp
                                            
                                       }
                                       else if( data.response.status[i] == "In Progress")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#FFFF99"};
                                          projectsName1[count4++]= temp
                                       }
                                       else if( data.response.status[i] == "Completed")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#CCFF99"};
                                          projectsName1[count4++]= temp
                                       }
                                     
                                              
                                               
                                   }
                                    
                                   $scope.ArrayProject1 = projectsName1
                                 
                                   
                               }
             
            
                      }).error(function(data,status,headers,config){
                                      alert("fetching error in project list")
                      });

                           
                   }         
                //end reserved function
                
              }
 
              
              // sprintboard controller -------------------------------------------------------
              function sprintBoardController($location,$routeParams,$scope,$http,flash){
                 
               var sessionToken = document.getElementById("token")
             
               this.params = $routeParams;
               var project_id = this.params.projectId 
               var release_id = this.params.releaseId
               $scope.startdate = this.params.releaseStartDate
               $scope.enddate = this.params.releaseEndDate
               $scope.projectNAME =this.params.projectName
               $scope.releaseNAME =this.params.releaseName
               $scope.projectID = project_id
               $scope.releaseID = release_id

               $scope.selectedFilter="All"
  
               $scope.getPageCount = function(filterOption) {
                    $scope.selectedFilterVar = filterOption
                     var paginationArray = new Array();
                     var countpaginationArray = 1
                     
                     $http.get("http://10.132.160.215:8080/iceScrum/getPageCountForSprints", {
                                        params: { token: sessionToken.value , rid: release_id , filterOption:filterOption }
                      }).success(function(data,status,headers,config){
                               
                                  
                             if( data.response.code == 200)
                               {   
                                   for (var i = data.response.pageCount ; i>0 ; i=i-4)
                                   {
                                     var temp = { "count": countpaginationArray ,"startIndex":(countpaginationArray-1)*4,"endIndex":((countpaginationArray-1)*4)+3};
                                     paginationArray[countpaginationArray] = temp
                                     countpaginationArray++
                                   }
                                      
                                      
                                   $scope.paginationArray = paginationArray
                                   $scope.fetchCreatedSprints(filterOption,0,3)
                               }
             
            
                      }).error(function(data,status,headers,config){
                                      alert("fetching error")
                      });

                   }
 
                 
               // fetch all the sprints which are created by this perticular user ---------- (on board)
               $scope.fetchCreatedSprints = function(filterOption,firstIndex,lastIndex) {
                       
                        var newArrayColor1 = new Array();
                        var newArrayColor2 = new Array();
                        var newArrayColor3 = new Array();

                        var count1 = 0
                        var count2 = 0
                        var count3 = 0
                        
                      $http.get("http://10.132.160.215:8080/iceScrum/sprint", {
                                             params: { token: sessionToken.value , rid: release_id ,filterOption:filterOption,firstIndex:firstIndex,lastIndex:lastIndex}
                         }).success(function(data,status,headers,config){
 
                                
                               if( data.response.code == 200)
                               {
                                     
                                   for(var i=0 ; i < data.response.id.length ; i++)
                                   {
                                        
                                      if( data.response.status[i] == "Todo")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"desc": data.response.description[i],"status":data.response.status[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i]};
                                          newArrayColor1[count1++]= temp
                                       }
                                       else if( data.response.status[i] == "In Progress")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"desc": data.response.description[i],"status":data.response.status[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i]};
                                          newArrayColor2[count2++]= temp
                                       }
                                       else if( data.response.status[i] == "Completed")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"desc": data.response.description[i],"status":data.response.status[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i]};
                                          newArrayColor3[count3++]= temp
                                       }
                                               
                                   }
                                     
                                     
                                   $scope.ArrayColor1 = newArrayColor1
                                   $scope.ArrayColor2 = newArrayColor2
                                   $scope.ArrayColor3 = newArrayColor3
                                   
                               }
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Fetching error in sprint hai")

                          });

                       
                   }
    
                 
                   // save the sprint for this user who is manager of this project --------------
                   $scope.sprintStatus = "Todo"
                   $scope.saveSprint = function() {
                     
                     var desc= "'"+$scope.sprintDescription+"'"
                        
                     var userStoryArrayString = "0-";
                     for(var i=0 ; i<$scope.selectedUserStorys.length ; i++)
                     { 
                         userStoryArrayString += $scope.selectedUserStorys[i].id
                         if (i !=$scope.selectedUserStorys.length-1){
                          userStoryArrayString += "-";
                         }
                     }
                       
                     var temp = '{token='+sessionToken.value+',rid='+release_id+',name='+$scope.sprintName+',description='+desc+',status='+$scope.sprintStatus+',startdate='+$scope.sprintStartDate+',enddate='+$scope.sprintEndDate+',userStorys='+userStoryArrayString+'}'

                     $http.post("http://10.132.160.215:8080/iceScrum/sprint",temp).success(function(data,status,headers,config){
                                    if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                    else if(data.response.code == 300 || 
                                            data.response.code == 600)
                                    //  alert(data.response.status)
                                      flash.success=data.response.status
                      }).error(function(data,status,headers,config){
                                      alert("Data is not valid !!!!!!!")
                      });
                        
                  } 
                    
                    
                    
                    
                    
                // first fetch the data for update the sprint   --------------------------------------------------  
                $scope.FetchDataForUpdateSprint = function(sprint_id,name,desc,startDate,endDate) {
                    
                  $scope.sprintId = sprint_id
                  $scope.sprintName = name
                  $scope.sprintDescription = desc
                  $scope.sprintStartDate = startDate
                  $scope.sprintEndDate = endDate
          
                } 
   
                // update the sprint which are created by this perticular user      --------------------------
                 $scope.updateSprint = function() {
                     var desc= "'"+$scope.sprintDescription+"'"
                     var userStoryArrayString = "0-";
                     for(var i=0 ; i<$scope.selectedUserStorys.length ; i++)
                     { 
                         userStoryArrayString += $scope.selectedUserStorys[i].id
                         if (i !=$scope.selectedUserStorys.length-1){
                          userStoryArrayString += "-";
                         }
                     }
                     var temp = '{token='+sessionToken.value+',sid='+$scope.sprintId+',name='+$scope.sprintName+',description='+desc+',startdate='+$scope.sprintStartDate+',enddate='+$scope.sprintEndDate+',userStorys='+userStoryArrayString+'}'

                     $http.put("http://10.132.160.215:8080/iceScrum/sprint",temp).success(function(data,status,headers,config){
                                    if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                   // alert(data.response.status)
                                    else if(data.response.code == 300 || data.response.code == 600)
                                      flash.success=data.response.status
                      }).error(function(data,status,headers,config){
                                      alert("Error")
                      });
                        
                }     
             
                 $scope.releaseName = this.params.releaseName
                 //fetch all sprints for perticular release -----------
                 $scope.fetchSprintsForSpecificRelease= function(){
                            
                          var release_name = $scope.releaseName
                          var sprintArray = new Array();
                          var countSprint = 0
                          //new
                          $http.get("http://10.132.160.215:8080/iceScrum/SprintsForSpecificRelease", {
                                             params: { token: sessionToken.value , release_name: release_name}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               for(var i=0 ; i < data.response.id.length ; i++)
                                               {
                                                         var temp = {"id": data.response.id[i] , "name":data.response.name[i]};
                                                         sprintArray[countSprint++]= temp
                                                    
                                               }
                                                 
                                               $scope.availableSprint = sprintArray
                                               countSprint = 0
                                                   
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          });
                  }
                  
                     // save the userStory for specific release and project
                     $scope.saveUserStory = function() {
                    var desc= "'"+$scope.userStoryDescription+"'"
                     
                     var temp = '{token='+sessionToken.value+',project_id='+project_id+',release_id='+release_id+',sprint_name='+$scope.selectedSprint+',name='+$scope.userStoryName+',description='+desc+'}'

                     $http.post("http://10.132.160.215:8080/iceScrum/UserStoryForSpecificRelease",temp).success(function(data,status,headers,config){
                                    if(data.response.code == 200)
                                    {
                                      location.reload()
                                    }
                                    else
                                      alert(data.response.status)
                      }).error(function(data,status,headers,config){
                                      alert("Error")
                      });
                  }  
                  
                  



                     // page count for user story in sprintboard 
                    $scope.getPageCountForUserStory = function() {
                    
                     var paginationArray = new Array();
                     var countpaginationArray = 1
                     
                     $http.get("http://10.132.160.215:8080/iceScrum/getPageCountForUserStoryInSprintBoard", {
                                        params: { token: sessionToken.value , project_id: project_id , release_id : release_id  }
                      }).success(function(data,status,headers,config){
                               
                                   
                             if( data.response.code == 200)
                               {   
                                   for (var i = data.response.pageCount ; i>0 ; i=i-4)
                                   {
                                     var temp = { "count": countpaginationArray ,"startIndex":(countpaginationArray-1)*4,"endIndex":((countpaginationArray-1)*4)+3};
                                     paginationArray[countpaginationArray] = temp
                                     countpaginationArray++
                                   }
                                      
                                      
                                   $scope.paginationArrayForUserStory = paginationArray
                                   
                               }
             
            
                      }).error(function(data,status,headers,config){
                                      alert("fetching error in userstory")
                      });

                   }
                    
                   // fetch the userStory according to specific release and project

                  $scope.fetchUserStorysForSpecificRelease= function(firstIndex , lastIndex){
                  
                        var UserStoryforSprint = new Array();
                        var countUserStoryforSprint = 0
                        
                         $http.get("http://10.132.160.215:8080/iceScrum/UserStoryForSpecificRelease", {
                                             params: { token: sessionToken.value , project_id: project_id , release_id:release_id , firstIndex:firstIndex,lastIndex:lastIndex}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               for(var i=0 ; i < data.response.id.length ; i++)
                                               {
                                                       

                                                         var temp = {"id": data.response.id[i] , "name":data.response.name[i],"desc": data.response.description[i]};
                                                         UserStoryforSprint[countUserStoryforSprint++]= temp

                                                        
                                               }
                                                 
                                               $scope.UserStoryforSprint = UserStoryforSprint
                                                 
                                                   
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          });
                          

                     } 
              
                  // first fetch the data for update the userStory   --------------------------------------------------  
                  $scope.FetchDataForUpdateUserStory = function(userStory_id,name,desc) {

                    $scope.userStoryId = userStory_id
                    $scope.userStoryName = name
                    $scope.userStoryDescription = desc

                  } 
                    
                  // update the userStory 
                  $scope.updateUserStory = function() {
                      
                     var desc= "'"+$scope.userStoryDescription+"'"
                     var temp = '{token='+sessionToken.value+',userStory_id='+$scope.userStoryId+',name='+$scope.userStoryName+',description='+desc+',sprint_name='+$scope.selectedSprint+'}'

                     $http.put("http://10.132.160.215:8080/iceScrum/UserStoryForSpecificRelease",temp).success(function(data,status,headers,config){
                                  if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                   
                      }).error(function(data,status,headers,config){
                                      alert("client side error !!!!!!!")
                      });
                        
                }      
                       
                       
                 // add task from sprintBoard ------
                 
                 $scope.fetchUserStoriesForSpecificSprint= function(){
                          var sprint_name = $scope.selectedSprint
                            
                          var userStoriesArray = new Array();
                          var countUserStories = 0
                         
                          $http.get("http://10.132.160.215:8080/iceScrum/fetchUserStoriesForSpecificSprint", {
                                             params: { token: sessionToken.value , sprint_name: sprint_name}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                           
                                               for(var i=0 ; i < data.response.id.length ; i++)
                                               { 
                                                         var temp = {"id": data.response.id[i] , "name":data.response.name[i]};
                                                         userStoriesArray[countUserStories++]= temp
                                                    
                                               }
                                                 
                                               $scope.availableUserStories = userStoriesArray
                                               countUserStories = 0
                                                  
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          });
                      
                            $http.get("http://10.132.160.215:8080/iceScrum/fetchDatesForParticularSprint", {
                                             params: { token: sessionToken.value , sprint_name: sprint_name}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               $scope.sDate = data.response.startDate
                                               $scope.eDate = data.response.endDate
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          }); 
                  }
                 
                  // fetch all registered users for assign the task      
                $scope.fetchUsers= function(){
                           
                         $http.get("http://10.132.160.215:8080/iceScrum/fetchUsersForTask", {
                                             params: { token: sessionToken.value}
                         }).success(function(data,status,headers,config){
                                         
                                      $scope.usersArray = data
                                       
                          }).error(function(data,status,headers,config){
                             
                                           alert("Fetching Error")

                          });

                  }  
                  
                  
                  // save the task data on the server
                $scope.taskStatus = "Todo"
                $scope.saveTask = function() {
                      
                    var desc= "'"+$scope.taskDescription+"'"
                   var temp = '{token='+sessionToken.value+',project_id='+project_id+',sprint_name='+$scope.selectedSprint+',name='+$scope.taskName+',description='+desc+',status='+$scope.taskStatus+',userStory='+$scope.taskUserStories+',user='+$scope.taskUsers+'}'

                     $http.post("http://10.132.160.215:8080/iceScrum/saveTaskFromReleaseBoard",temp).success(function(data,status,headers,config){
                                    if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                    else if(data.response.code == 300|| data.response.code == 600 )
                                      flash.success=data.response.status
                      }).error(function(data,status,headers,config){
                                      alert("Error")
                      });
                        
                } 
                
                 // reserved function for project list which is common for all pages 
       
                   $scope.fetchCreatedProject = function() {
                    
                      var projectsName1 = new Array();
                     // var projectsName2 = new Array();
                      //var projectsName3 = new Array();
                     $scope.currentPage = 0;
                     $scope.pageSize = 5;
                      var count4 = 0
                    //  var count5 = 0
                     // var count6 = 0
                     
                     $http.get("http://10.132.160.215:8080/iceScrum/GetProjectList", {
                                        params: { token: sessionToken.value }
                      }).success(function(data,status,headers,config){
                              
                                       
                             if( data.response.code == 200)
                               {
                                     $scope.length=data.response.id.length
                                
                               $scope.numberOfPages=Math.ceil($scope.length/$scope.pageSize)
                                   for(var i=0 ; i < data.response.id.length ; i++)
                                   {
                                      if( data.response.status[i] == "Todo")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#CCE5FF"};
                                          projectsName1[count4++]= temp
                                            
                                       }
                                       else if( data.response.status[i] == "In Progress")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#FFFF99"};
                                          projectsName1[count4++]= temp
                                       }
                                       else if( data.response.status[i] == "Completed")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#CCFF99"};
                                          projectsName1[count4++]= temp
                                       }
                                                                                        
                                   }
                                    
                                   $scope.ArrayProject1 = projectsName1
                                   
                               }
             
            
                      }).error(function(data,status,headers,config){
                                      alert("fetching error in project list")
                      });

                           
                   }         
                //end reserved function
                   
             }
            
            
            //taskboard controller -------------------------------------------------------------------
             function taskBoardController($location,$routeParams,$scope,$http,flash){
                 
               var sessionToken = document.getElementById("token")
             
               this.params = $routeParams;
               var project_id = this.params.projectId 
               var release_id = this.params.releaseId
               var sprint_id = this.params.sprintId
               $scope.projectNAME =this.params.projectName
               $scope.releaseNAME =this.params.releaseName
               $scope.sprintNAME =this.params.sprintName
               $scope.projectID = project_id
               $scope.releaseID = release_id
               $scope.sprintID = sprint_id
               
               $scope.startdate= this.params.sprintStartDate;
               $scope.enddate= this.params.sprintEndDate;
      
               $scope.selectedFilter="All"
    
               $scope.getPageCount = function(filterOption) {
                    $scope.selectedFilterVar = filterOption
                     var paginationArray = new Array();
                     var countpaginationArray = 1
                     
                     $http.get("http://10.132.160.215:8080/iceScrum/getPageCountForTasks", {
                                        params: { token: sessionToken.value ,  sid: sprint_id , filterOption:filterOption }
                      }).success(function(data,status,headers,config){
                               
                                  
                             if( data.response.code == 200)
                               {   
                                   for (var i = data.response.pageCount ; i>0 ; i=i-4)
                                   {
                                     var temp = { "count": countpaginationArray ,"startIndex":(countpaginationArray-1)*4,"endIndex":((countpaginationArray-1)*4)+3};
                                     paginationArray[countpaginationArray] = temp
                                     countpaginationArray++
                                   }
                                      
                                      
                                   $scope.paginationArray = paginationArray
                                   $scope.fetchCreatedTasks(filterOption,0,3)
                               }
             
            
                      }).error(function(data,status,headers,config){
                                      alert("fetching error")
                      });

                   }
                 
                 
                 
                 
               // fetch all the tasks which are created by this perticular user ----------
               $scope.fetchCreatedTasks = function(filterOption,firstIndex,lastIndex) {
               
                       var newArrayColor1 = new Array();
                       var newArrayColor2 = new Array();
                       var newArrayColor3 = new Array();

                       var count1 = 0
                       var count2 = 0
                       var count3 = 0

               
                     $http.get("http://10.132.160.215:8080/iceScrum/task", {
                                             params: { token: sessionToken.value , sid: sprint_id ,filterOption:filterOption,firstIndex:firstIndex,lastIndex:lastIndex}
                         }).success(function(data,status,headers,config){

                               if( data.response.code == 200)
                               {
                                     
                                   for(var i=0 ; i < data.response.id.length ; i++)
                                   {
                                        
                                      if( data.response.status[i] == "Todo")
                                       {
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"assignTo":data.response.assignTo[i],"userStory":data.response.userStory[i]};
                                          newArrayColor1[count1++]= temp
                                       }
                                       else if( data.response.status[i] == "In Progress")
                                       {
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"assignTo":data.response.assignTo[i],"userStory":data.response.userStory[i]};
                                          newArrayColor2[count2++]= temp
                                       }
                                       else if( data.response.status[i] == "Completed")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"assignTo":data.response.assignTo[i],"userStory":data.response.userStory[i]};
                                          newArrayColor3[count3++]= temp
                                       }
                                               
                                   }
                                     
                                     
                                   $scope.ArrayColor1 = newArrayColor1
                                   $scope.ArrayColor2 = newArrayColor2
                                   $scope.ArrayColor3 = newArrayColor3
                                   
                               }
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Fetching error")

                          });

                       
                   }
                     
  
                // fetch all registered users for assign the task      
                $scope.fetchUsers= function(){
                           
                         $http.get("http://10.132.160.215:8080/iceScrum/fetchUsersForTask", {
                                             params: { token: sessionToken.value}
                         }).success(function(data,status,headers,config){
                                         
                                      $scope.usersArray = data
                                       
                          }).error(function(data,status,headers,config){
                             
                                           alert("Fetching Error")

                          });

                  }  
                    
                  var tempArrayUserStory = new Array();
                  var counter = 0
                            
                 // fetch all userStorys for this perticular sprint and add this userStory to task
                 $scope.fetchUserStorysForSpecificSprint= function(){
                           
                         $http.get("http://10.132.160.215:8080/iceScrum/UserStoryForSpecificSprint", {
                                             params: { token: sessionToken.value , project_id: project_id , release_id : release_id , sprint_id : sprint_id }
                         }).success(function(data,status,headers,config){
                               if( data.response.code == 200)
                               {
                                     
                                   for(var i=0 ; i < data.response.id.length ; i++)
                                   {
                                                  
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i]};
                                          tempArrayUserStory[counter++]= temp  
                                            
                                   }
                                    
                                   $scope.userStorysArrayForSprint = tempArrayUserStory
                                     
                                   
                               }
                                       
                                       
                          }).error(function(data,status,headers,config){
                             
                                           alert("Fetching Error in userStory")

                          });

                 }  
                       
               // save the task data on the server
                $scope.taskStatus = "Todo"
                $scope.saveTask = function() {
                      
                    var desc= "'"+$scope.taskDescription+"'"
                   var temp = '{token='+sessionToken.value+',project_id='+project_id+',sid='+sprint_id+',name='+$scope.taskName+',description='+desc+',status='+$scope.taskStatus+',userStory='+$scope.taskUserStorys+',user='+$scope.taskUsers+'}'

                     $http.post("http://10.132.160.215:8080/iceScrum/task",temp).success(function(data,status,headers,config){
                                    if(data.response.code == 200)
                                    {
                                      location.reload()                 
                                    }
                                    else if(data.response.code == 300 || data.response.code == 600 || data.response.code == 800)
                                     // alert(data.response.status)
                                       flash.success=data.response.status
                      }).error(function(data,status,headers,config){
                                      alert("Error in save ")
                      });     
                } 
   
                  
                // first fetch the data for update the Task   --------------------------------------------------  
                $scope.FetchDataForUpdateTask = function(task_id,name,desc,assignTo,userStoryName) {
                    
                  $scope.taskId = task_id
                  $scope.taskName = name
                  $scope.taskDescription = desc
                  
                  $scope.prevAssign = assignTo
                  $scope.prevUserStory = userStoryName
                  

                } 
   
                // update the task which are created by this perticular user      --------------------------
                $scope.updateTask = function() {
                    var desc= "'"+$scope.taskDescription+"'"
                     var temp = '{token='+sessionToken.value+',tid='+$scope.taskId+',name='+$scope.taskName+',description='+desc+',userStory='+$scope.taskUserStorys+',user='+$scope.taskUsers+'}'
                      
                     $http.put("http://10.132.160.215:8080/iceScrum/task",temp).success(function(data,status,headers,config){
                                    if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                    else if(data.response.code == 300)
                                    flash.success=data.response.status
                      }).error(function(data,status,headers,config){
                                      alert("Error ")
                      });
                        
                } 
                
                // reserved function for project list which is common for all pages 
       
                   $scope.fetchCreatedProject = function() {
                    
                      var projectsName1 = new Array();
                      $scope.currentPage = 0;
                      $scope.pageSize = 5;
                      var count4 = 0
                     
                     $http.get("http://10.132.160.215:8080/iceScrum/GetProjectList", {
                                        params: { token: sessionToken.value }
                      }).success(function(data,status,headers,config){
                              
                                       
                             if( data.response.code == 200)
                               {
                                     $scope.length=data.response.id.length
                                
                                     $scope.numberOfPages=Math.ceil($scope.length/$scope.pageSize)
                                   for(var i=0 ; i < data.response.id.length ; i++)
                                   {
                                      if( data.response.status[i] == "Todo")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#CCE5FF"};
                                          projectsName1[count4++]= temp
                                            
                                       }
                                       else if( data.response.status[i] == "In Progress")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#FFFF99"};
                                          projectsName1[count4++]= temp
                                       }
                                       else if( data.response.status[i] == "Completed")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#CCFF99"};
                                          projectsName1[count4++]= temp
                                       }
                                               
                                   }
                                    
                                   $scope.ArrayProject1 = projectsName1
                                   
                               }
             
            
                      }).error(function(data,status,headers,config){
                                      alert("fetching error in project list")
                      });

                           
                   }         
                //end reserved function
       
              }


              //allTaskboard controller -------------------------------------------------------------------
             function allTaskBoardController($location,$routeParams,$scope,$http,flash){
             
                var sessionToken = document.getElementById("token")
                this.params = $routeParams;
                var project_id = this.params.projectId;
               
                
                  // page count for allTask in allTaskBoard 
                    $scope.getPageCountForAllTask = function() {
                    
                     var paginationArray = new Array();
                     var countpaginationArray = 1
                     
                     $http.get("http://10.132.160.215:8080/iceScrum/getPageCountForAllTask", {
                                        params: { token: sessionToken.value , project_id: project_id  }
                      }).success(function(data,status,headers,config){
                               
                                   
                             if( data.response.code == 200 )
                               {   
                                   for (var i = data.response.pageCount ; i>0 ; i=i-4)
                                   {
                                     var temp = { "count": countpaginationArray ,"startIndex":(countpaginationArray-1)*4,"endIndex":((countpaginationArray-1)*4)+3};
                                     paginationArray[countpaginationArray] = temp
                                     countpaginationArray++
                                   }
        
                                   $scope.paginationArrayForAllTask = paginationArray
                                   
                               }
             
            
                      }).error(function(data,status,headers,config){
                                      alert("fetching error in pagecount")
                      });

                   }
                    
                //fetch all the task for specific project
                $scope.fetchAllTaskForSpecificProject = function(firstIndex,lastIndex) {
                
                   var newArrayColor1 = new Array();
                   var newArrayColor2 = new Array();
                   var newArrayColor3 = new Array();
                   var count1 = 0
                   var count2 = 0
                   var count3 = 0

                   $http.get("http://10.132.160.215:8080/iceScrum/fetchAllTaskForSpecificProject", {
                                             params: { token: sessionToken.value , project_id: project_id ,firstIndex:firstIndex,lastIndex:lastIndex}
                         }).success(function(data,status,headers,config){
                              
                               if( data.response.code == 200)
                               {
                                     
                                   for(var i=0 ; i < data.response.id.length ; i++)
                                   {
      
                                       if( data.response.status[i] == "Todo")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"assignTo":data.response.assignTo[i],"userStory":data.response.userStory[i],"sprintName":data.response.sprint_name[i]};
                                          newArrayColor1[count1++]= temp
                                            
                                       }
                                       else if( data.response.status[i] == "In Progress")
                                       {
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"assignTo":data.response.assignTo[i],"userStory":data.response.userStory[i],"sprintName":data.response.sprint_name[i]};
                                          newArrayColor2[count2++]= temp
                                       }
                                       else if( data.response.status[i] == "Completed")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"assignTo":data.response.assignTo[i],"userStory":data.response.userStory[i],"sprintName":data.response.sprint_name[i]};
                                          newArrayColor3[count3++]= temp
                                       }
                                           
                                   }
                                     
                                     
                                   $scope.allTaskArray1 = newArrayColor1
                                   $scope.allTaskArray2 = newArrayColor2
                                   $scope.allTaskArray3 = newArrayColor3
              
                               }
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Fetching error")

                          });

                }
                 
                 
                 
                
                  // fetch all releases for perticular project(in userStory Model and create task model ) -----------
                 var releasesArray = new Array();
                 var countRelease = 0
                   
                 $scope.fetchReleasesForSpecificProject= function(){
                         
                           
                         $http.get("http://10.132.160.215:8080/iceScrum/ReleasesForSpecificProject", {
                                             params: { token: sessionToken.value , project_id: project_id}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               for(var i=0 ; i < data.response.id.length ; i++)
                                               {
                                                       

                                                         var temp = {"id": data.response.id[i] , "name":data.response.name[i]};
                                                         releasesArray[countRelease++]= temp

                                                        
                                               }
                                                 
                                               $scope.availableRelease = releasesArray
                                                
                                                   
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          });
                            
                       

                     } 
             
                
                
                //fetch all sprints for perticular release -----------(in userstory model and create task model )
                   
                 $scope.fetchSprintsForSpecificRelease= function(){
                          var release_name = $scope.selectedRelease
                            
                          var sprintArray = new Array();
                          var countSprint = 0
                         
                          $http.get("http://10.132.160.215:8080/iceScrum/SprintsForSpecificRelease", {
                                             params: { token: sessionToken.value , release_name: release_name}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               for(var i=0 ; i < data.response.id.length ; i++)
                                               {
                                                         var temp = {"id": data.response.id[i] , "name":data.response.name[i]};
                                                         sprintArray[countSprint++]= temp
                                                    
                                               }
                                                 
                                               $scope.availableSprint = sprintArray
                                               countSprint = 0
                                                
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          });
                          
                      
                  }
                
                
                 //fetch all userStories for perticular sprint and sprint date also -----------(in task model)
                   
                 $scope.fetchUserStoriesForSpecificSprint= function(){
                          var sprint_name = $scope.selectedSprint
                            
                          var userStoriesArray = new Array();
                          var countUserStories = 0
                         
                          $http.get("http://10.132.160.215:8080/iceScrum/fetchUserStoriesForSpecificSprint", {
                                             params: { token: sessionToken.value , sprint_name: sprint_name}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               for(var i=0 ; i < data.response.id.length ; i++)
                                               {
                                                         var temp = {"id": data.response.id[i] , "name":data.response.name[i]};
                                                         userStoriesArray[countUserStories++]= temp
                                                    
                                               }
                                                 
                                               $scope.availableUserStories = userStoriesArray
                                               countUserStories = 0
                                                  
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          });
                          
                           $http.get("http://10.132.160.215:8080/iceScrum/fetchDatesForParticularSprint", {
                                             params: { token: sessionToken.value , sprint_name: sprint_name}
                         }).success(function(data,status,headers,config){
                                          if(data.response.code == 200)
                                          {
                                               $scope.sDate = data.response.startDate
                                               $scope.eDate = data.response.endDate
                                          }
                                        
                                       
                          }).error(function(data,status,headers,config){
                                           alert("Error"+data)

                          }); 
                  }
                  
                  
                   // fetch all registered users for assign the task      
                $scope.fetchUsers= function(){
                           
                         $http.get("http://10.132.160.215:8080/iceScrum/fetchUsersForTask", {
                                             params: { token: sessionToken.value}
                         }).success(function(data,status,headers,config){
                                      $scope.usersArray = data
                          }).error(function(data,status,headers,config){
                                           alert("Fetching Error")
                          });
                  }
                  
                  
                   $scope.FetchDataForUpdateTask= function(id,name,desc){
                  
                   $scope.taskId = id
                   $scope.taskName = name
                   $scope.taskDescription = desc

                        $http.get("http://10.132.160.215:8080/iceScrum/fetchTaskInfo", {
                                             params: { token: sessionToken.value , task_id : id}
                         }).success(function(data,status,headers,config){
                                     
                                     $scope.prevUserStory = data.response.userStory
                                     $scope.prevAssign = data.response.assignTo
                                     $scope.prevSprint = data.response.sprintName
                                     
                          }).error(function(data,status,headers,config){
                                           alert("Fetching Error")
                          });



                   }
                   
                  $scope.updateTask= function(){ 
                    
                     var desc= "'"+$scope.taskDescription+"'"
                     var temp = '{token='+sessionToken.value+',task_id='+$scope.taskId+',name='+$scope.taskName+',description='+desc+',userStory='+$scope.taskUserStories+',user='+$scope.taskUsers+',sprint_name='+$scope.selectedSprint+'}'
                      
                     $http.put("http://10.132.160.215:8080/iceScrum/updateTaskFromAllTask",temp).success(function(data,status,headers,config){
                                    if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                    else if(data.response.code == 300)
                                    flash.success=data.response.status
                      }).error(function(data,status,headers,config){
                                      alert("Error ")
                      });


                  }
                  
                  
                  
                // save the task data on the server
                $scope.taskStatus = "Todo"
                $scope.saveTask = function() {
                      
                    var desc= "'"+$scope.taskDescription+"'"
                   var temp = '{token='+sessionToken.value+',project_id='+project_id+',sprint_name='+$scope.selectedSprint+',name='+$scope.taskName+',description='+desc+',status='+$scope.taskStatus+',startdate='+$scope.taskStartDate+',enddate='+$scope.taskEndDate+',userStory='+$scope.taskUserStories+',user='+$scope.taskUsers+'}'

                     $http.post("http://10.132.160.215:8080/iceScrum/saveTaskFromReleaseBoard",temp).success(function(data,status,headers,config){
                                    if(data.response.code == 200)
                                    {
                                        
                                      location.reload()
                                          
                                    }
                                   
                                    else if( data.response.code == 300 || data.response.code == 600 || data.response.code == 800 )
                                      flash.success=data.response.status
                      }).error(function(data,status,headers,config){
                                      alert("Error")
                      });
                        
                } 
                
                
                
                
                
                // reserved function for project list which is common for all pages 
       
                   $scope.fetchCreatedProject = function() {
                    
                      var projectsName1 = new Array();
                    //  var projectsName2 = new Array();
                    //  var projectsName3 = new Array();
                      $scope.currentPage = 0;
                      $scope.pageSize = 5;
                      var count4 = 0
                     // var count5 = 0
                     // var count6 = 0
                     
                     $http.get("http://10.132.160.215:8080/iceScrum/GetProjectList", {
                                        params: { token: sessionToken.value }
                      }).success(function(data,status,headers,config){
                              
                                       
                             if( data.response.code == 200)
                               {
                                  $scope.length=data.response.id.length
                                
                               $scope.numberOfPages=Math.ceil($scope.length/$scope.pageSize)
                                     
                                   for(var i=0 ; i < data.response.id.length ; i++)
                                   {
                                      if( data.response.status[i] == "Todo")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#CCE5FF"};
                                          projectsName1[count4++]= temp
                                            
                                       }
                                       else if( data.response.status[i] == "In Progress")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#FFFF99"};
                                          projectsName1[count4++]= temp
                                       }
                                       else if( data.response.status[i] == "Completed")
                                       {
                                            
                                          var temp = {"id": data.response.id[i] , "name":data.response.name[i],"status":data.response.status[i],"desc": data.response.description[i],"startDate":data.response.dateCreated[i],"endDate":data.response.endDate[i],"updateDate":data.response.lastUpdated[i],"color":"#CCFF99"};
                                          projectsName1[count4++]= temp
                                       }
                                               
                                   }
                                    
                                   $scope.ArrayProject1 = projectsName1
                                  // $scope.ArrayProject2 = projectsName2
                                  // $scope.ArrayProject3 = projectsName3
                                   
                               }
             
            
                      }).error(function(data,status,headers,config){
                                      alert("fetching error in project list")
                      });

                           
                   }         
                //end reserved function
                   
             }
      
    </script>  

  </body>
</html>