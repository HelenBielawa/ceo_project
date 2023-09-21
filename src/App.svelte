<script>
import Scrolly from "./helpers/Scrolly.svelte";
import GridBackground from "./components/GridBackground.svelte";
import Scatterplot from "./components/Scatterplot.svelte";
import Questionaire from "./components/Questionaire.svelte";
import StepContentEnglish from "./data/stepContent.json";
import StepContentCatalan from "./data/stepContentCatalan.json";
import socioDemData from "./data/clusters_socioeconomic.json";
import politicalClusterData from "./data/politicalClusters.json";
import projectionRight from "./data/projectionTable_RIGHT.json";
import projectionIndep from "./data/projectionTable_INDEP.json";
import QuizUserData from "./data/quizUserData.json";
import html2canvas from "html2canvas";
import {FileEarmarkFont, FileImage, ArrowDownCircle} from "svelte-bootstrap-icons";

$: isEnglish = true; // Default language is English
$: StepContent = StepContentEnglish;

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
$: console.log("thisuserdata: ", thisUserData)

$: currentStatus = "politicalViz";

let politicalData = politicalClusterData.map(d => ({"RIGHT_PRED": d["RIGHT.QUANT_Pred_Mean"],
                                  "INDEP_PRED": d["INDEP.QUANT_Pred_Mean"],
                                  "Cluster": d.Political_Cluster,
                                  "Perc_Users": d.Perc_Users,
                                "Twin": false}));

let socioClusterData = socioDemData.map(d => ({"RIGHT_PRED": d.RIGHT_Pred_Mean,
                                                        "INDEP_PRED": d.INDEP_Pred_Mean,
                                                        "Cluster": d.Cluster,
                                                        "Perc_Users": d.Perc_Users * 100,
                                                        "Twin": d.Twin}));

let data;

$: answer = [];
let currentAnswer;


$: {
      currentStepContent = StepContent[currentStep];
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
              currentStatus = "sociodemViz";
              data = socioClusterData;
            }
            else if(currentStepContent.tag === "userPolData"){
              currentStatus = "politicalViz";
              data = politicalData;
              data = data.filter(d => d.Cluster != 100)
              data.push(thisUserPos(thisUserData));
            }
            else if (currentStepContent.tag === "statisticalTwin"){
              socioClusterData = matchTwin(thisUserData, socioClusterData);
              data = socioClusterData;
              currentStatus = "sociodemViz";
            }
            else{
              currentStatus = "politicalViz";
              data = politicalData;
            }
        }
        else{

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

      function getValue(arr, code){
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

      return {"RIGHT_PRED": RIGHT_POS * 100,
              "INDEP_PRED": INDEP_POS * 100,
              "Cluster": 100,
            "Perc_Users": 0,
          "Twin": false}
    }

    function matchTwin(thisUserData, socioClusterData){
    ///This function updates the socioDemData and writes "true" in the twin value of the matching Cluster

      //all values from user data
      let values = thisUserData.map(d => d.data).flat()
      //id of the cluster that the user belongs to
      let twinClusterID = 0;
      let languageCode;
      if (values.find(v => v.code === "CATALAN_ONLY").value === 1){
        languageCode = 1;
      }
      else if (values.find(v => v.code === "SPANISH_ONLY").value === 1){
        languageCode = 2;
      }
      else{
        languageCode = 0;
      }

      try{
        twinClusterID = socioDemData.find(sc => sc.AGE_RANGE === String(values.find(v => v.code === "AGE_RANGE").value)
                          && sc.LANGUAGE === languageCode
                          && sc.EDUCATION === values.find(v => v.code === "EDUCATION").value)
                    .Cluster
      }
      catch{
        twinClusterID = 0;
      }
      console.log("twinID:", twinClusterID)

      //twin = true for the cluster that the user belongs to
      socioClusterData = socioClusterData.map(sc => {
                                  if (sc.Cluster === twinClusterID){
                                    console.log("id match", twinClusterID)
                                    return({"RIGHT_PRED": sc.RIGHT_PRED,
                                            "INDEP_PRED": sc.INDEP_PRED,
                                              "Cluster": sc.Cluster,
                                              "Perc_Users": sc.Perc_Users,
                                              "Twin": true});
                
                                    }
                                  else{
                                    return({"RIGHT_PRED": sc.RIGHT_PRED,
                                            "INDEP_PRED": sc.INDEP_PRED,
                                              "Cluster": sc.Cluster,
                                              "Perc_Users": sc.Perc_Users,
                                              "Twin": false});
                                  }
                          }
                        )
      return socioClusterData;
    }
    function downloadImage() {
    const chartElement = document.querySelector('.chart');
    html2canvas(chartElement).then(canvas => {
      const imgData = canvas.toDataURL("image/png");
      let a = document.createElement('a');
      a.href = imgData;
      a.download = 'scatterplot.png';
      a.click();
    });
    }
</script>

<body>

  <button class="language-switcher" on:click={toggleLanguage}>
    <FileEarmarkFont/>
    {isEnglish ? 'Catalan' : 'English'}
  </button>

<div class="flex">
  <div class="chart">
  <GridBackground {isEnglish}/>
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
          <div class="arrow">
          <ArrowDownCircle class="compass"/>
          </div>
       </div>
      </div>
       {/each} 
       <button class="download-button hidden" on:click={downloadImage} class:hidden={currentStep !== StepContent.length - 1}>
        <FileImage/>
        Download Chart
      </button>
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
  opacity: 1;
  transition: opacity 300ms ease;
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 2;
}

.step-content {
  background: #ccc; /* Adjust background color as needed */
  padding: 3rem 3rem;
  border-radius: 3px;
  width: 40vw;
  color: black;
  opacity: 1;
  line-height: 150%;
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
    
  .arrow {
    font-size: 2em; /* Adjust size as needed */
  animation: bounce 2s infinite;
  color: #000; /* Adjust color as needed */
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
  .download-button {
  position: fixed;
  bottom: 20px;
  right: 20px;
  z-index: 9999;
  background: #ccc;
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

  @keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-15px);
  }
  60% {
    transform: translateY(-10px);
  }
}

@media (max-width: 800px){
      .chart {
      width: 100vw; /* Adjust width as needed */
      height: 100vw;
      overflow: visible;
      flex: 0 0 auto;
    }
      .aside {
      flex: 1 1 auto;
      bottom: 0; /* Adjust positioning based on the width of the left element */
      left: 0;
      top: 100vw;
      width: 100vw;
      height: auto;
      background-color: white; /* Adjust background color as needed */
      overflow-y: scroll;
      overflow: auto;
    }
    .flex {
      display: flex;
      flex-direction: column;
      flex-wrap: wrap;
      justify-content: flex-start;
      align-items: flex-end;
      align-content: flex-end;
      overflow: hidden;
      height: 100vh;
      margin: 0;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      position: fixed;
    }
    .step {
    position: relative;
    width: 100vw;
    margin: 0%;
    opacity: 0.3;
    transition: opacity 300ms ease;
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 2;
  }
  .step-content {
  background: #ccc; /* Adjust background color as needed */
  padding: 1rem 1rem;
  border-radius: 3px;
  width: 100vw;
  color: black;
  line-height: 120%;
}
.step.active{
  opacity: 0.6;
}
}

</style>
