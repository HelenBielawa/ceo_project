<script>
    import QuizUserData from "../data/quizUserData.json";

    export let text;
    export let type;
    export let options;
    export let id;
    export let step;

    export let thisUserData;

    console.log("Question!!!");
    console.log(thisUserData);
    console.log(step);
    console.log(id);

    $:currentAnswer = thisUserData.filter(d => d.question_id === id).length > 0? 
            thisUserData.find(d => d.question_id === id).answer : "";

   let answer = thisUserData.filter(d => d.question_id === id)//.answer ; ""//id === 'undefined'?
        //"" : thisUserData.find(d => d.question_id === id).answer ;
        console.log(answer);

    function handleAnswer(ans){
        //adding the corresponding code to the user data table
        thisUserData = thisUserData.map((slot) => {
            if (slot.question_id === step.id) { //find the correct slot
                let option = step.options.filter(o => o.opt === ans)[0];
                slot.answer = ans;
                slot.value = option.value;
                slot.code = option.code;
                console.log(option);
                console.log(slot.data);
                /*slot.data = slot.data.map((data) => { //change the slot data
                if (data.code === option.code) {
                    data.value = option.value;
                }*/
                //return data;
                //});
        }
        return slot;
      })
    }
</script>
  
  <div
    class="question-{type}"
  >
    <p><b>Question {id}/13: </b>{text}</p>
    {#if step.question_type === "Multiple"}
        <fieldset>
            {#each options as option, i}
                <div>
                    <label for={option}>{option}</label>
                    {#if currentAnswer === option} 
                        <input type="radio" bind:group={answer} name="answer" value={option} checked
                        on:input={() => {handleAnswer(option)}}>
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
  