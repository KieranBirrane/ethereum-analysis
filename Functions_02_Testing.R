##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ### Functions ### ##### ##### ##### ##### ##### #####
##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####



# getLabels
test_getLabels <- getLabels()
test_getLabels



# setupBlockFile
test_setupBlockFile <- setupBlockFile(0,100)
test_setupBlockFile



# createSubject
test_createSubject <- createSubject(0,100)
test_createSubject

test_createSubject <- createSubject(0,100,"Request")
test_createSubject



# createMessage
test_createMessage <- createMessage(5,0,10)
test_createMessage

test_createMessage <- createMessage(5,0,10,1)
test_createMessage

test_createMessage <- createMessage(5,0,10,2)
test_createMessage

test_createMessage <- createMessage(5000,420001,500000,3)
test_createMessage



# createTemplate
test_createTemplate <- createTemplate("d14127984@mydit.ie","d14127984@mydit.ie",test_createSubject)
test_createTemplate
  


# createEmailFromTemplate
test_createEmailFromTemplate <- createEmailFromTemplate(test_createTemplate,test_createMessage)
test_createEmailFromTemplate



# sendMessageWithLabel
test_sendMessageWithLabel <- sendMessageWithLabel(test_createEmailFromTemplate)
test_sendMessageWithLabel



# setEmailToProcessed
test_setEmailToProcessed <- setEmailToProcessed(test_createEmailFromTemplate)
test_setEmailToProcessed



# getRequestInfo
test_getRequestInfo <- getRequestInfo()
test_getRequestInfo



# getBlockLoop
test_getBlockLoop <- getBlockLoop(0,10,5, test_template)
test_getBlockLoop


