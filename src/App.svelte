<script>
import Scrolly from "./helpers/Scrolly.svelte";
import GridBackground from "./components/GridBackground.svelte";
import Scatterplot from "./components/Scatterplot.svelte";
import Question from "./components/Question.svelte";
let currentStep;
const steps = [ {type:"text",text:"Catalans are scattered!"}, 
                {type:"question", text:"Explaining the groups...", options:["Yes","No"]},
                {type:"question", text: "Highlighting some results...", options:["Low", "Medium", "High"]}
              ];
/*               "WHERE DO YOU STAND?", "political quiz", 
              "see the results in the plot!",
              "statistical questions quiz", "compare reality to statistical twin", "end"];
 */
$: answer = [];

</script>

<main>
<section>
  <div class="sticky">
  <GridBackground/>
  <Scatterplot/>

</div>
<div class="steps">

  <Scrolly bind:value={currentStep}> <!-- 3. This is what updates value -->
    {#each steps as step, i}
        <div class="step" class:active={currentStep === i}> <!-- 4. Dynamically applies the active class -->
          <div class="step-content">
            {#if step.type === "text"}
              <p>{step.text}</p>
            {:else if  step.type === "question"}
              <Question text = {step.text} type = "Multiple" options = {step.options} bind:answer = {answer[currentStep]}/>
            {/if}
          </div>
        </div>
    {/each}
</Scrolly>
</div>
<div class="current_step">
  <p>Current Scroll Step: {currentStep}</p>
  <p>Current answer: {JSON.stringify(answer)}</p>
</div>
</section>

</main>

<style>
section{
  position: relative;
}
.sticky{
  position: sticky;
  top: 0;
  z-index: 1;
}
.steps{
  position: relative;
  z-index: 2;
}
.step{
  height: 90vh;
  width: 30vw;
  opacity: 0.3;
  transition: opacity 300ms ease;
  display: flex;
  justify-content: center;
  place-items: center;
}
.step-content{
  background: grey;
  border: 1px solid;
  padding: 0.75rem 1rem;
  border-radius: 3px;
  width: 60vw;
  color: black;
}
.step.active{
  opacity: 0.6;
}
.current_step{
  position:fixed;
  bottom: 0;
  right:0;
  padding:2;
}
</style>
