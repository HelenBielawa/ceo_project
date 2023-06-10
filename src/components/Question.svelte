<script>
    export let text;
    export let type;
    export let options;
    export let answer;
</script>
  
  <div
    class="question-{type}"
  >
    <p><b>Question: </b>{text}</p>
    {#if type === "Multiple"}
        <fieldset>
            {#each options as option, i}
                <div>
                    <label for={option}>{option}</label>
                    {#if answer === option} 
                        <input type="radio" bind:group={answer} name="answer" value={option} checked >
                    {:else}
                        <input type="radio" bind:group={answer} name="answer" value={option} >
                    {/if}
                </div>
            {/each}
        </fieldset>
    {/if}
<!--     <p><b>Answer: </b>{answer}</p> -->
  </div>
  
  <style>

  </style>
  