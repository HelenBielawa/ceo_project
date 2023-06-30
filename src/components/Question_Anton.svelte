<script>
    export let text;
    export let type;
    export let options;
    export let id;
    export let step;
    export let thisUserData;
    
 $: answer = "";


    function handleAnswer(answer){
        //adding the corresponding code to the user data table
        thisUserData = thisUserData.map((slot) => {
            if (slot.question_id === step.id) { //find the correct slot
                let option = step.options.filter(o => o.opt === answer)[0];
                slot.answer = answer;
                slot.data = slot.data.map((data) => { //change the slot data
                if (data.code === option.code) {
                    data.value = option.value;
                }
                if (answer === "Catalonia"){
                    if (data.code === "BORN_ABROAD"){
                        data.value = 0;
                    }
                }
                else if (answer === "Rest of Spain" || answer === "Somewhere else in the EU" || answer === "Other"){
                    if (data.code === "BORN_CATALONIA"){
                        data.value = 0;
                    }
                }
                else if (answer === "Catalan"){
                    if (data.code === "SPANISH_ONLY"){
                        data.value = 0;
                    }
                }
                else if (answer === "Spanish"){
                    if (data.code === "CATALAN_ONLY"){
                        data.value = 0;
                    }
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
    <p><b>Question {id}: </b>{text}</p>
    {#if step.question_type === "Multiple"}
        <fieldset>
            {#each options as option, i}
                <div>
                    <label for={option}>{option}</label>
                    {#if answer === option} 
                        <input type="radio" bind:group={answer} name="answer" value={option} checked/>
                    {:else}
                        <input type="radio" bind:group={answer} name="answer" value={option}
                        on:input={() => {handleAnswer(option)}}/>
                    {/if}
                </div>
            {/each}
        </fieldset>
    {/if}
  </div>
  
  <style>
  </style>