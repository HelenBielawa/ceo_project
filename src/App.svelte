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

<body>

<div class="flex">
  <div class="chart">
  <GridBackground/>
  <Scatterplot/>
  </div>

  <div class="aside">
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
</div>

</body>
<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
html, body {
  height: 100vh;
  width: 100vw;
  margin: 0;
  padding: 0;
  overflow: hidden;
}
.flex {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
  justify-content: flex-start;
  align-items: stretch;
  align-content: stretch;
  overflow: hidden;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  position: fixed;
}
.chart {
  position: absolute;
  width: 100vh; /* Adjust width as needed */
  height: 100vh;
  overflow: visible;
}
.aside {
  position: absolute;
  right: 0;
  left: 100vh; /* Adjust positioning based on the width of the left element */
  height: 100vh;
  background-color: white; /* Adjust background color as needed */
  flex: 1;
  overflow-y: scroll;
}

.step {
  position: relative;
  height: 90vh;
  margin: 5%;
  opacity: 0.3;
  transition: opacity 300ms ease;
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 2;
}

.step-content {
  background: #ccc; /* Adjust background color as needed */
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
