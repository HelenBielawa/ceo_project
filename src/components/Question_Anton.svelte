<script>
    import QuizUserData from "../data/quizUserData.json";
    export let text;
    export let type;
    export let options;
    export let id;
    export let step;
    export let thisUserData;
    console.log("Question");
    console.log(thisUserData);
    console.log(step);
    console.log(id);
 $: answer = ""

   $: {
    if (thisUserData.find(d => d.question_id === id) !== 'undefined'){
        let test = thisUserData.find(d => d.question_id === id)
    }
    else{
        let test = "";
    }
    
   }

    
   $:{
 /*    console.log("Question answer")
    console.log(answer)
    console.log(thisUserData.find(d => d.question_id === id));
 */   }
    function handleAnswer(answer){
        //adding the corresponding code to the user data table
        console.log("Question handleanswer")
                console.log(answer);
        thisUserData = thisUserData.map((slot) => {
            if (slot.question_id === step.id) { //find the correct slot
                let option = step.options.filter(o => o.opt === answer)[0];
                slot.answer = answer;
                console.log(option);
                console.log(slot);
                slot.data = slot.data.map((data) => { //change the slot data
                if (data.code === option.code) {
                    data.value = option.value;
                }
                return data;
                });
        }
        return slot;
      })
    }
</script>
  
  <div
    class="question-{type}"
  >
    <p><b>Question {id}/15: </b>{text}</p>
    {#if step.question_type === "Multiple"}
        <fieldset>
            {#each options as option, i}
                <div>
                    <label for={option}>{option}</label>
                    {#if answer === option} 
                        <input type="radio" bind:group={answer} name="answer" value={option} checked>
                    {:else}
                        <input type="radio" bind:group={answer} name="answer" value={option}
                        on:input={() => {handleAnswer(option)}}>
                    {/if}
                </div>
            {/each}
        </fieldset>
    {:else if step.question_type === "Range"}
        <input type="range" id="rangeInput" min="0" max="10" value="5">        
    {/if}
<!--     <p><b>Answer: </b>{answer}</p> -->
  </div>
  
  <style>
  </style>