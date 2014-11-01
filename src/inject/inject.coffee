#TODO: 
#DONE add score
#DONE ish make the css pretty
#Add drop down or autocomplete
#make something really magical happen when they win
# add little sorting animations
removedPhotos = false
toggleForm = (lientry) ->
  #toggle what is showing
  quiz = lientry.find(".hr_quiz").fadeToggle()
  basics = lientry.find(".basics").fadeToggle()
  #if basics.visible()

showQuiz = (lientry) ->
  quiz = lientry.find(".hr_quiz").fadeIn()
  basics = lientry.find(".basics").fadeOut()
  #if basics.visible()

showNormal = (lientry) ->
  lientry.find(".hr_quiz").fadeOut()
  lientry.find(".basics").fadeIn()
  #if basics.visible()

increaseScore = (isExpert) ->
  score = $(".score_correct")
  if isExpert
    score = $(".score_correct_first")
  newScore = parseInt(score.text()) + 1
  score.text(newScore.toString())


checkAnswer = (clickedObject, basicsSelector, answerSelector, textProcessing) ->

  #split the answer into letters
  answerArray = clickedObject.val().toLowerCase().split("")

  #create a REGEX that allows for people to sort of mistype things
  answerRegex = "^.?"
  for letInd of answerArray
    answerRegex += (answerArray[letInd] + ".?")
  answerRegex += "$"
  answerRegex = new RegExp(answerRegex)

  #find the actual answer from the original person's bamboo hr profile
  answer = clickedObject.parent().next(".basics").find(basicsSelector).text()#.split(",")
  
  #If this answer needs to be additionally processed, run the passed in function, then trim it
  if textProcessing
    answer = textProcessing(answer).trim()

  #Get the place where you put information about whether it was correct or not
  answerSpan = clickedObject.next(answerSelector)

  #unless they did not type the correct answer (or something close b/c it's a regex)
  unless answer.toLowerCase().search(answerRegex) is -1
    console.log "Correct the answer is " + answer

    #check if they got it right on the first try by checking the length of the hint
    increaseScore(false)
    #increase expert level
    if answerSpan.text().length < 1 
      increaseScore(true)

    fadeTextChange(answerSpan, "Correct the answer is " + answer)

    #change the input to the answer and make it unclickable
    clickedObject.val(answer)
    clickedObject.prop("readonly", true)

    #update that you've solve this so that it can see if you've solved all the questions related with this
    solvelevel = clickedObject.parent().attr('solved')
    solvelevel -= 1
    clickedObject.parent().attr('solved', solvelevel)
    console.log("solved level is " + solvelevel)

    #if you've solved everything at this point
    if solvelevel <= 0
      console.log("solved!")
      #change it back to normal
      toggleForm(clickedObject.parent().parent())
  else
    #update the amount of hint you're giving and give them a hint
    hintlevel = parseInt(answerSpan.attr("hint")) + 1
    fadeTextChange(answerSpan, "Incorrect, but here's a hint: " + answer.substring(0, hintlevel))
    answerSpan.attr "hint", hintlevel.toString()
  return

fadeTextChange = (boxToFade, textToFade) ->
  boxToFade.fadeOut 200, ->
    $(this).text(textToFade).fadeIn(200)


putRandomPos = (entryselector, max) ->
  loc1 = Math.floor((Math.random() * max));
  loc2 = Math.floor((Math.random() * max));
  $(entryselector[loc1]).insertBefore($(entryselector[loc2]))


setUpGame = () ->

  #collect all the possible options for title
  titlesArr = []
  for loc in $(".location")
    curText = $(loc).text().split("-")[0].trim()
    if curText not in titlesArr
      titlesArr.push curText

  #console.log titlesArr


  scorearea = $("<div class=\"score_area\">"+
      "<h3>PRESS ENTER TO SUBMIT YOUR GUESS FOR NAME/TITLE AND GOOD LUCK</h3>"+
      "<span class=\"score_text\"><h2>Score:</h2>"+
      "<span class=\"score_correct\"></span>/"+"<span class=\"score_total\"></span></span><br>"+
      "<span class=\"score_text\"><h2>Expert Mode Score:</h2>"+
      "<span class=\"score_correct_first\"></span>/<span class=\"score_total\"></span></span>"+
    "</div>")
  scorearea.insertAfter $(".intro_area")

  quiz_element = $("<div class=\"hr_quiz\" solved=\"0\"> <span class=\"sp_name span_q_title\">First name:</span><input type=\"text\" name=\"name\" class=\"em_name question\"><span hint=\"0\" class=\"an_name hintcont\"></span><br> <span class=\"sp_team span_q_title\">Team:</span> <select name=\"title\" class=\"em_team question\"></select><span class=\"an_team hintcont\" hint=\"0\"></span> </div>")

  #Putting the different possibilities into the array for teams
  quiz_element.find('select').append("<option value=\"nonetype\">Select A Team</option>");
  for title in titlesArr
    if title.trim() != ""
      quiz_element.find('select').append("<option value=\"" + title.toLowerCase().replace(/\s/g, '') + "\">" + title + "</option>");

  NUM_QUESTIONS = 2
  #console.log("The number of questions is " + NUM_QUESTIONS) 
  quiz_element.attr('solved', NUM_QUESTIONS)

  quiz_element.insertBefore $(".basics")

  $(".em_name").keyup (e) ->
    if e.keyCode is 13
      checkAnswer($(this), "dt", ".an_name", (e) ->
        e = e.split(",")
        return e[1])

  $(".em_team").change (e) ->
    #if e.keyCode is 13
    checkAnswer($(this), $(".location"), ".an_team", (e) ->
      e = e.split("-")
      return e[0])

  return NUM_QUESTIONS




resetGame = (numinputs) ->

  #get all of the employee photos
  emPics = $(".empPhoto")

  #make a number of swaps equal to the number of employees
  swaps = $(".entry").length - 1

  #count how many employees are lame (don't have a picture)
  totalEmpPic = 0

  console.log("the number of entries is " + swaps)

  #for all of the employees, as long as they aren't the stock image, swap em, count em
  for el in $(".basics").parent()
    console.log("The photo's src is " + $(el).find(emPics).attr("src"))
    if !(/udacity.bamboohr.com/.test($(el).find(emPics).attr("src")) || ($(el).find(emPics).attr("src") == chrome.extension.getURL('images/faceless.png')))
      showQuiz($(el))
      totalEmpPic++
    #swap around
  
  #Fade in the scores
  $(".score_total").text(totalEmpPic*2)
  $(".score_correct").text("0")
  $(".score_correct_first").text("0")
  $(".score_area").fadeIn()
  
  #swap em around
  for i in [0..swaps*2] by 1
    putRandomPos($(".entry"), swaps)

  #set all the hints to 0  
  $('.hintcont').attr('hint', '0')
  quizel = $('.hr_quiz')

  #set solved to the number of inputs
  quizel.attr('solved', numinputs)

  #set the input blank and the hint text blank
  quizel.find("input").val("")
  $(".hintcont").text("")

  #remove the letterheadings that have no children
  for header, i in $(".letterHeader")
    if $(header).find("li").length < 1
      console.log("removing " + header)
      $(header).remove()

  #if there are lame photos
  if !removedPhotos
    for photo in emPics
      #check if the photo is lame, then switch it

      if /udacity.bamboohr.com/.test($(photo).attr("src")) 
        $(photo).attr("src",chrome.extension.getURL('images/faceless.png'))
    removedPhotos = true


chrome.extension.sendMessage {}, (response) ->
  readyStateCheckInterval = setInterval(->
    if document.readyState is "complete"
      clearInterval readyStateCheckInterval
      
      # ----------------------------------------------------------
      # This part of the script triggers when page is done loading
      console.log "Hello. This message was sent from scripts/inject.js"
      
      # ----------------------------------------------------------
      
      intro = $("<h3>Hi....Jon?</h3><div class=\"intro_area\">Udacity's gotten a lot bigger since the good ol' days. Do you really know that new Course Developer's name? The friendly one who always says hi in the morning? Wasn't it Mark? Sam? Jon..a..if...er?<br/><br/><button class=\"play_button\" type=\"button\">Prove Your Name-Fu</button></div>")
      intro.insertAfter $("#contentTop")

      
      
      $(".play_button").click ->
        $(".branded-icon").css("visibility", "hidden")
        $(".entry").css("border-bottom", "solid #d9d9d9 1px")
        resetGame(NUM_QUESTIONS)

      NUM_QUESTIONS = setUpGame()



      return
      

  #console.log(nameEntered);
  
  # if ( $( "input:first" ).val() === "correct" ) {
  #     //$( "span" ).text( "Validated..." ).show();
  #     return;
  # }
  #   $( "span" ).text( "Not valid!" ).show().fadeOut( 1000 );
  #   event.preventDefault();
  , 10)
  return
