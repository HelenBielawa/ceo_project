<script>
import Scrolly from "./helpers/Scrolly.svelte";
import GridBackground from "./components/GridBackground.svelte";
import Scatterplot from "./components/Scatterplot.svelte";
import Question from "./components/Question.svelte";
import StepContent from "./data/stepContent.json";
import {Compass, WindowDash} from "svelte-bootstrap-icons";

$: currentStep = 0;
$: console.log("in the main app, curr Step: ", currentStep);

$: answer = [];
let currentAnswer;

</script>

<body>

<div class="flex">
  <div class="chart">
  <GridBackground/>
  <Scatterplot {currentStep}/>
  </div>

  <div class="aside">

    <Scrolly bind:value={currentStep}> <!-- This is what updates value -->
      {#each StepContent as step, i}
          <div class="step" class:active={currentStep === i}> <!-- 4. Dynamically applies the active class -->
            <div class="step-content">
              {#if step.type === "text"}
                <p>{step.text}</p>
              {:else if step.type == "header"}
                <h1>{step.h1}</h1>
                <h3>{step.h3}</h3>
              {:else if  step.type === "question"}
                <Question text = {step.text} id= {step.id} type = {step.question_type}
                options = {step.options.map(o => o.opt)}
                {step}/>
              {/if}
            </div>

            <div class="scroll-indicator-container">
              <div class="compass">
              <Compass class="compass"/>
              </div>
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
h1, h2, h3, h4, h5, h6 {
  font-family: 'Rubik', sans-serif;
  font-weight: 600;
  margin: 5%;
}
body {
  font-family: 'Montserrat', sans-serif;
  font-weight: 400;
}
  .scroll-indicator-container {
    position:absolute;
    bottom: 20px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 100;
  }
  
  .compass {
    animation: spin 3s linear infinite;
    fill: #000;
    width: 24px;
    height: 24px;
    transform-style: preserve-3d;
    left: 50%;
    bottom: 20px;
    position: relative;
    transform-origin: center center;
  }
  
  @keyframes spin {
    0% {
      transform: translateX(-50%) rotateX(0deg);
    }
    100% {
      transform: translateX(-50%) rotateX(360deg);
    }
  }
</style>
