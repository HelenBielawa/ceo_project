<script>
    import Question from "./Question.svelte";
    import StepContentEnglish from "../data/stepContent.json";
    import StepContentCatalan from "../data/stepContentCatalan.json";

    export let language;
    export let questions;
    export let minId;
    export let maxId;
    export let thisUserData;

    console.log(questions);

    let step = questions;//language? StepContentEnglish : StepContentCatalan;

    $: id = minId;

    $: currentQuestion = step.find(d => d.id === id);

    $:{
        console.log("currentQuestion.options");
        console.log(currentQuestion.options);
    }

    function previous(){
        if(id > minId){
            id--;
        }
        console.log(thisUserData);
    }
    function next(){
        if(id < maxId){
            id++;
        }
        console.log(thisUserData);
    }
</script>
  
  <div
    class="questionaire"
  >
  
    <p><b>{language?"Questionaire":"Qüestionari"}</b></p>
    <Question text = {currentQuestion.text} id= {id} type = {currentQuestion.question_type}
    options = {currentQuestion.options.map(o => o.opt)}
    step = {currentQuestion}
    bind:thisUserData/>
    <div class="pagination">
        <button disabled='{id ===  minId}' on:click={previous}>Previous</button>
        <button disabled='{id ===  maxId}' on:click={next}>Next</button>
    </div>
  </div>
  
  <style>

  </style>
  