<head>
    <link rel="stylesheet" type="text/css" href="http://192.168.1.51/css/style.css">
    <title>Momentum 2 | Index </title>
<!-- script type="text/javascript" src="http://192.168.1.51/js/main.js"></script> -->
<script type="text/javascript">
function uploadFile() 
{
  	// alert("Here");

    var files = document.getElementById("file").files;
 
    if(files.length > 0 )
    {
       // alert("2");

       var formData = new FormData();
       formData.append("file", files[0]);
 
       var xhttp = new XMLHttpRequest();
 
       // Set POST method and ajax file path
       xhttp.open("POST", "ajax.php", true);
 
      // call on request changes state
       xhttp.onreadystatechange = function() {
          if (this.readyState == 4 && this.status == 200) {
 
            var response = this.responseText;
            if(response == 1){
               alert("Upload successfully.");
            }else{
               alert("File not uploaded.");
            }
          }	
       };
 
 		// alert("3");
       	// Send request with data
       	xhttp.send(formData);
  		// alert("4");
 		alert("Everything right");
    }
    else
    {
       alert("Please select a file");
    }
 }
 </script>

</head>

<body>
  
    <br><br>
    <h1>Momentum 2</h1>
    <p id="prova"></p>
    <br><br>

<script> 
var x = document.createElement("INPUT");
x.setAttribute("type", "file");
document.body.appendChild(x);
</script>

    <a href="#img1">
        <img class="thumb" src="http://192.168.1.51/img/c.jpg">
    </a>
    <!-- lightbox container hidden with CSS -->
    <div class="lightbox" id="img1">
        <a href="#img3" class="light-btn btn-prev">prev</a>
            <a href="#_" class="btn-close">X</a>
             <img src="http://192.168.1.51/img/c.jpg" onclick="uploadFile()"/>
        <a href="#img2" class="light-btn btn-next">next</a>
    </div>

    <a href="#img2">
      <img class="thumb" src="http://192.168.1.51/img/b.jpg">
    </a>
    <!-- lightbox container hidden with CSS -->
    <div class="lightbox" id="img2">
        <a href="#img1" class="light-btn btn-prev">prev</a>
            <a href="#_" class="btn-close">X</a>
            <img src="http://192.168.1.51/img/b.jpg" onclick="uploadFile()"/>
        <a href="#img3" class="light-btn btn-next">next</a>
    </div>

    <a href="#img3">
      <img class="thumb" src="http://192.168.1.51/img/a.jpg">
    </a>
    <!-- lightbox container hidden with CSS -->
    <div class="lightbox" id="img3">
        <a href="#img2" class="light-btn btn-prev">prev</a>
            <a href="#_" class="btn-close">X</a>
            <img src="http://192.168.1.51/img/a.jpg" onclick="uploadFile()"/>
        <a href="#img1" class="light-btn btn-next">next</a>
    </div>
    <p class="footer">~ Castles fall from inside</p>
</body>
