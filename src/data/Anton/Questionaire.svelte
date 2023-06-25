<script>
    import Question from "./Question.svelte";
    import StepContentEnglish from "../data/stepContent.json";
    import StepContentCatalan from "../data/stepContentCatalan.json";

    export let language;
    export let thisUserData;

    const maxQuestions = 15;

    let step = language? StepContentEnglish : StepContentCatalan;

    $: id = 1;

    $: currentQuestion = step.find(d => d.id === id);

    $:{
        console.log("currentQuestion.options");
        console.log(currentQuestion.options);
    }

    function previous(){
        if(id > 1){
            id--;
        }
        console.log(thisUserData);
    }
    function next(){
        if(id < maxQuestions){
            id++;
        }
        console.log(thisUserData);
    }
</script>
  
  <div
    class="questionaire"
  >
  
    <p><b>Questionaire</b></p>
    <Question text = {currentQuestion.text} id= {id} type = {currentQuestion.question_type}
    options = {currentQuestion.options.map(o => o.opt)}
    step = {currentQuestion}
    bind:thisUserData/>
    <div class="pagination">
        <button disabled='{id ===  1}' on:click={previous}>Previous</button>
        <button disabled='{id ===  maxQuestions}' on:click={next}>Next</button>
    </div>
  </div>
  
  <style>

  </style>
  