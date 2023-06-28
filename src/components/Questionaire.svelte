<script>
    import Question from "./Question_Anton.svelte";
    import StepContentEnglish from "../data/stepContent.json";
    import StepContentCatalan from "../data/stepContentCatalan.json";
console.log("in the questionaire")
    export let language;
    export let questions;
    export let minID;
    export let maxID;
    export let thisUserData;

    let step = questions;

    $: id = minID;

    $: currentQuestion = step.find(d => d.id === id);

    function previous(){
        if(id > minID){
            id--;
        }
        console.log(thisUserData);
    }
    function next(){
        if(id < maxID){
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
        <button disabled='{id ===  minID}' on:click={previous}>Previous</button>
        <button disabled='{id ===  maxID}' on:click={next}>Next</button>
    </div>
  </div>
  
  <style>

  </style>
  