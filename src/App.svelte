<script>
import Scrolly from "./helpers/Scrolly.svelte";
import GridBackground from "./components/GridBackground.svelte";
import Scatterplot from "./components/Scatterplot.svelte";
import Question from "./components/Question_Anton.svelte";
import Questionaire from "./components/Questionaire.svelte";
import StepContentEnglish from "./data/stepContent.json";
import StepContentCatalan from "./data/stepContentCatalan.json";
import socioDemData from "./data/clusters_socioeconomic.json";
import politicalClusterData from "./data/politicalClusters.json";
import projectionRight from "./data/projectionTable_RIGHT.json";
import projectionIndep from "./data/projectionTable_INDEP.json";
import QuizUserData from "./data/quizUserData.json";
import {Compass, FileEarmarkFont} from "svelte-bootstrap-icons";

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

let thisUserData = QuizUserData;

$: currentStatus = "politicalViz";

let politicalData = politicalClusterData.map(d => ({"RIGHT_PRED": d["RIGHT.QUANT_Pred_Mean"],
                                  "INDEP_PRED": d["INDEP.QUANT_Pred_Mean"],
                                  "Cluster": d.Political_Cluster,
                                  "Perc_Users": d.Perc_Users}));

let socioClusterData = socioDemData.map(d => ({"RIGHT_PRED": d.RIGHT_Pred_Mean,
                                                        "INDEP_PRED": d.INDEP_Pred_Mean,
                                                        "Cluster": d.Cluster,
                                                        "Perc_Users": d.Perc_Users * 100}));

let data;

$: answer = [];
let currentAnswer;


$: {
      currentStepContent = StepContent[currentStep];
      console.log("we are checking the Content of step ", currentStep)
        if(currentStepContent){
          if ("tag" in currentStepContent){
            if (currentStepContent.tag === "start-header" || currentStepContent.tag === "start-intro"){
              data = [];
              currentStatus = "start";
            }
            else if (currentStepContent.tag === "top-left"){
              currentStatus = "top-left"
            }
            else if (currentStepContent.tag === "sociodemData"){
              console.log("Status: sociodemViz")
              currentStatus = "sociodemViz";
              data = socioClusterData;
            }
            else if(currentStepContent.tag === "userPolData"){
              console.log("Status: politicalViz")
              currentStatus = "politicalViz";
              data = politicalData;
              console.log("I want to push data, this is userdata: ", thisUserData);
              data = data.filter(d => d.Cluster != 100)
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

      let values = thisUserData.map(d => d.data).flat()
      console.log("values: ", values)

      function getValue(arr, code){
        console.log("arr", arr)
        console.log("code", code)
          let value = arr.find(d => d.code === code).value
          return value
        }

      //predicting the independece-stance
      let INDEP_PRED = 0.156 * 1
                      + 0.075 * getValue(values,"CATALAN_ONLY")
                      -0.048 * getValue(values,"SPANISH_ONLY")
                      +0.023 * getValue(values,"SPAIN_ONLY")
                      + 0.016 * getValue(values,"BORN_CATALONIA")
                      + 0.049 * getValue(values,"BORN_ABROAD")
                      + 0.011 * getValue(values,"SELF_DETERM")
                      + 0.166 * getValue(values,"BELONGING");
      //predicting the independence-stance
      let RIGHT_PRED = 0.457 * 1
                      + 0.000 * getValue(values,"ACTITUD_ECONOMIA")
                      + 0.009 * getValue(values,"ACTITUD_IMPOSTOS")
                      -0.023 * getValue(values,"ACTITUD_INGRESSOS")
                      + 0.021 * getValue(values,"ACTITUD_AUTORITAT")
                      -0.024 * getValue(values,"ACTITUD_RELIGIO")
                      + 0.019 * getValue(values,"ACTITUD_OBEIR")
                      + 0.018 * getValue(values,"ACTITUD_IMMIGRACIO")
                      + 0.008 * getValue(values,"ACTITUD_MEDIAMBIENT");

      //finding out the position in the chart
      let INDEP_POS = findClosest(INDEP_PRED, projectionIndep);
      let RIGHT_POS = findClosest(RIGHT_PRED, projectionRight)

      console.log("indeppos: ", INDEP_POS * 100);
      console.log("rightpos: ", RIGHT_POS * 100);
      return {"RIGHT_PRED": RIGHT_POS * 100,
              "INDEP_PRED": INDEP_POS * 100,
              "Cluster": 100,
            "Perc_Users": 0}
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
  <Scatterplot {currentStep} {data} {currentStatus} {socioClusterData}/>
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
          {:else if  step.type === "questionaire"}
            <Questionaire language = {isEnglish} minID = {step.minId} maxID = {step.maxId} 
            questions={step.questions} bind:thisUserData/>
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
