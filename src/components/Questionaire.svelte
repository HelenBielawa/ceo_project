<script>
    import Question from "./Question.svelte";
    export let language;
    export let questions;
    export let minID;
    export let maxID;
    export let thisUserData;
 
    $: step = questions;

    $: id = minID;

    $: currentQuestion = step.find(d => d.id === id);

    function previous(){
        if(id > minID){
            id--;
        }
    }
    function next(){
        if(id < maxID){
            id++;
        }
    }
</script>
  
  <div
    class="questionaire"
  >
  
  <p><b>{language?"Questionaire":"Qüestionari"}</b></p>
    <Question text = {currentQuestion.text} id= {id} type = {currentQuestion.question_type}
    options = {currentQuestion.options.map(o => o.opt)}
    step = {currentQuestion}
    maxID = {maxID}
    bind:thisUserData/>
    <div class="pagination">
        <button disabled='{id ===  minID}' on:click={previous}>Previous</button>
        <button disabled='{id ===  maxID}' on:click={next}>Next</button>
    </div>
  </div>
  
  <style>

  </style>
  