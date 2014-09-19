toggleForm = (lientry) ->
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

checkAnswer = (clickedObject, basicsSelector, answerSelector, textProcessing) ->

  answerArray = clickedObject.val().toLowerCase().split("")
  answerRegex = "^.?"
  for letInd of answerArray
    answerRegex += (answerArray[letInd] + ".?")
  answerRegex += "$"
  answerRegex = new RegExp(answerRegex)
  answer = clickedObject.parent().next(".basics").find(basicsSelector).text()#.split(",")
  if textProcessing
    answer = textProcessing(answer).trim()
  console.log answerRegex
  console.log "pressed enter in the answer box"
  console.log "the text is " + answer

  answerSpan = clickedObject.next(answerSelector)

  unless answer.toLowerCase().search(answerRegex) is -1
    console.log "Correct the answer is " + answer
    fadeTextChange(answerSpan, "Correct the answer is " + answer)
    clickedObject.val(answer)
    clickedObject.prop("readonly", true)
    solvelevel = clickedObject.parent().attr('solved')
    solvelevel -= 1
    clickedObject.parent().attr('solved', solvelevel)
    console.log("solved level is " + solvelevel)
    if solvelevel <= 0
      console.log("solved!")
      toggleForm(clickedObject.parent().parent())
  else
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

  quiz_element = $("<div class=\"hr_quiz\" solved=\"0\"> First name:<input type=\"text\" name=\"name\" class=\"em_name\"><span hint=\"0\" class=\"an_name hintcont\"></span><br> Team: <input type=\"text\" name=\"title\" class=\"em_team\"><span class=\"an_team hintcont\" hint=\"0\"></span> </div>")

  NUM_INPUTS = quiz_element.find("input").length
  quiz_element.attr('solved', NUM_INPUTS)

  quiz_element.insertBefore $(".basics")

  $(".em_name").keyup (e) ->
    if e.keyCode is 13
      checkAnswer($(this), "dt", ".an_name", (e) ->
        e = e.split(",")
        return e[1])

  $(".em_team").keyup (e) ->
    if e.keyCode is 13
      checkAnswer($(this), $(".location"), ".an_team", (e) ->
        e = e.split("-")
        return e[0])
  return NUM_INPUTS




resetGame = (numinputs) ->
  for el in $(".basics").parent()
    showQuiz($(el))
    #swap around
  swaps = $(".entry").length - 1
  for i in [0..swaps] by 1
    putRandomPos($(".entry"), swaps)
  $('.hintcont').attr('hint', '0')
  quizel = $('.hr_quiz')
  quizel.attr('solved', numinputs)
  quizel.find("input").val("")
  $(".hintcont").text("")

chrome.extension.sendMessage {}, (response) ->
  readyStateCheckInterval = setInterval(->
    if document.readyState is "complete"
      clearInterval readyStateCheckInterval
      
      # ----------------------------------------------------------
      # This part of the script triggers when page is done loading
      console.log "Hello. This message was sent from scripts/inject.js"
      
      # ----------------------------------------------------------
      
      intro = $("<h1>Hi....Jon?</h1><div class=\"intro_area\">Udacity's gotten a lot bigger since the good ol' days. Do you really know that new Course Developer's name? The friendly one who always says hi in the morning? Wasn't it Mark? Sam? Jon..a..if...er?<br/><br/><button class=\"play_button\" type=\"button\">Prove Your Name-Fu</button></div>")
      intro.insertAfter $("#contentTop")

      scorearea = $("<div class=\"score_area\"><span class=\"score_text\">Score:<span class=\"score_correct\"></span>/<span class=\"score_total\"></span></span><br><span class=\"score_text\">Expert Mode Score:<span class=\"score_correct_first\"></span>/<span class=\"score_total\"></span></span></div>")
      
      $(".play_button").click ->
        $(".branded-icon").css("visibility", "hidden")
        $(".entry").css("border-bottom", "solid #d9d9d9 1px")
        resetGame(NUM_INPUTS)

      NUM_INPUTS = setUpGame()



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
