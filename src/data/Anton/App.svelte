<script>
import Scrolly from "./helpers/Scrolly.svelte";
import GridBackground from "./components/GridBackground.svelte";
import Scatterplot from "./components/Scatterplot.svelte";
import Question from "./components/Question.svelte";
import Questionaire from "./components/Questionaire.svelte";
import StepContentEnglish from "./data/stepContent.json";
import StepContentCatalan from "./data/stepContentCatalan.json";
import socioClusterData from "./data/clusters_socioeconomic.json";
import politicalClusterData from "./data/politicalClusters.json";
import projectionRight from "./data/projectionTable_RIGHT.json";
import projectionIndep from "./data/projectionTable_INDEP.json";
import {Compass, FileEarmarkFont} from "svelte-bootstrap-icons";
import QuizUserData from "./data/quizUserData.json";

let isEnglish = true; // Default language is English
let StepContent = StepContentEnglish;

function toggleLanguage() {
  isEnglish = !isEnglish;
  if (isEnglish){
    StepContent = StepContentEnglish;
  }
  else{
    StepContent = StepContentCatalan;
  }
}

$: currentStep = 0;
let currentStepContent;
let thisUserData  = QuizUserData;

$: currentStatus = "politicalViz";

let politicalData = politicalClusterData.map(d => ({"RIGHT_PRED": d.RIGHT_Pred_Mean,
                                  "INDEP_PRED": d.INDEP_Pred_Mean,
                                  "NUM": d.Num_Users}));

let sociodemData = socioClusterData.map(d => ({"RIGHT_PRED": d.RIGHT_Pred_Mean,
                                                        "INDEP_PRED": d.INDEP_Pred_Mean,
                                                        "NUM": d.Num_Users}));

let data = politicalData;

$: answer = [];
let currentAnswer;


$: {
      currentStepContent = StepContent[currentStep];
      console.log("we are checking the Content of step ", currentStep)
        if(currentStepContent){
          if ("tag" in currentStepContent){
            if (currentStepContent.tag === "sociodemData"){
              console.log("Status: sociodemViz")
              currentStatus = "sociodemViz";
              data = sociodemData;
            }
            else if(currentStepContent.tag === "userPolData"){
              console.log("Status: politicalViz")
              currentStatus = "politicalViz";
              data = politicalData;
              data.push(thisUserPos(thisUserData));
            }
            else{
              console.log("Status: politicalViz")
              currentStatus = "politicalViz";
              data = politicalData;
            }
        }
        else{
          console.log("Status: politicalViz")
          currentStatus = "politicalViz";
          data = politicalData;
        }
        }
      }

  function findClosest(num, array){
    let closest = array.reduce(function(prev, curr) {
                              return (Math.abs(curr.x - num) < Math.abs(prev.x - num) ? curr : prev);
                              }, ({x:0,quantile:0}));
    return closest.quantile;
  }

  function thisUserPos(thisUserData){

    function getValue(arr, code){
      console.log(arr);
      console.log(code);
      let pos = arr.map(e => e.code).indexOf(code);
      console.log(pos);
      if(pos !== -1){
        return arr[pos].value;
      }
      return 0;
    }

    //predicting the independece-stance
    let INDEP_PRED = 0.156 * 1
                    + 0.075 * getValue(thisUserData,"CATALAN_ONLY")
                    -0.048 * getValue(thisUserData,"SPANISH_ONLY")
                    +0.023 * getValue(thisUserData,"SPAIN_ONLY")
                    + 0.016 * getValue(thisUserData,"BORN_CATALONIA")
                    + 0.049 * getValue(thisUserData,"BORN_ABROAD")
                    + 0.011 * getValue(thisUserData,"SELF_DETERM")
                    + 0.166 * getValue(thisUserData,"BELONGING");
    //predicting the independence-stance
    let RIGHT_PRED = 0.457 * 1
                    + 0.000 * getValue(thisUserData,"ACTITUD_ECONOMIA")
                    + 0.009 * getValue(thisUserData,"ACTITUD_IMPOSTOS")
                    -0.023 * getValue(thisUserData,"ACTITUD_INGRESSOS")
                    + 0.021 * getValue(thisUserData,"ACTITUD_AUTORITAT")
                    -0.024 * getValue(thisUserData,"ACTITUD_RELIGIO")
                    + 0.019 * getValue(thisUserData,"ACTITUD_OBEIR")
                    + 0.018 * getValue(thisUserData,"ACTITUD_IMMIGRACIO")
                    + 0.008 * getValue(thisUserData,"ACTITUD_MEDIAMBIENT");

    //finding out the position in the chart
    let INDEP_POS = findClosest(INDEP_PRED, projectionIndep);
    let RIGHT_POS = findClosest(RIGHT_PRED, projectionRight)

    console.log(INDEP_POS * 100);
    console.log(RIGHT_POS * 100);
    return {"INDEP_PRED": INDEP_POS * 100,
            "RIGHT_PRED": RIGHT_POS * 100,
          "NUM": 0}
  }
</script>

<body>

  <button class="language-switcher" on:click={toggleLanguage}>
    <FileEarmarkFont/>
    {isEnglish ? 'Catalan' : 'English'}
  </button>

<div class="flex">
  <div class="chart">
  <GridBackground/>
  <Scatterplot {currentStep} {data} {currentStatus} socioClusterData={sociodemData}/>
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
                {step}
                bind:thisUserData/>
              {:else if  step.type === "questionaire"}
                <Questionaire language = {isEnglish} bind:thisUserData/>
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
  .language-switcher {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 9999;
    background: #ccc; /* Adjust background color as needed */
    padding: 0.5rem;
    border-radius: 3px;
    color: black;
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
