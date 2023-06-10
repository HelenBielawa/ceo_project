<script>
	import { createEventDispatcher } from 'svelte';

    export let text;
    export let type;
    export let options;
    export let answer;

    console.log(options);

    const dispatch = createEventDispatcher();
    
    $: change = (obj) => {
        console.log("Change question");
        dispatch('change', { value: answer });
    }

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
                        <input type="radio" bind:group={answer} name="answer" value={option} checked on:change={change(this)}>
                    {:else}
                        <input type="radio" bind:group={answer} name="answer" value={option} on:change={change(this)}>
                    {/if}
                </div>
            {/each}
        </fieldset>
    {/if}
    <p><b>Answer: </b>{answer}</p>
  </div>
  
  <style>

  </style>
  