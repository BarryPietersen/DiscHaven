//used when a user clicks add item - from the search results page or the product page

function addToShoppingCart(button) {
    if (!_isLoggedIn) {
        popupInfo(false, 'Please login to perform this action, or register and continue shopping'); 
        return;
    }

    var http = new XMLHttpRequest();
    var id = button.getAttribute('data-pid');

    http.onreadystatechange = function (http) {
        if (this.readyState === 4 && this.status === 200) {

            try {
                var obj = JSON.parse(this.responseText);

                if (obj.commandResult.ID > 0) {
                    document.getElementById('navCartCount').innerHTML = obj.cartCount.toString();
                    button.innerHTML = "Item Added<i class='fa fa-check ml-1'></i>";
                    return true;
                }
                else {
                    //display error message from json response
                    popupInfo(false, obj.commandResult.errorMessage, '', '');
                    return false;
                }
            }
            catch (e) {
                popupError(false, e.Message, '', '');
                return false;
            }

        }
        else if (this.readyState === 4 && this.status === 401) {
            popupInfo(false, 'Please login to perform this action, or register and continue shopping');
            return false;
        }
    };

    http.open('POST', 'http://localhost:52075/Account/AddShoppingCartItem/' + id.toString(), true);
    http.timeout = 3000;
    http.send();
}

function updateProductModal(id) {
    var modalContent = document.getElementById("modalContent");
    var spinner = document.getElementById("mspinner");
    modalContent.style.display = 'none';
    spinner.style.display = 'block';
    var http = new XMLHttpRequest();

    http.onreadystatechange = function () {
        if (this.readyState === 4 && this.status === 200) {
            try {
                var p = JSON.parse(this.responseText);

                if (p.ID > 0) {
                    //the data is ready for modal
                    document.getElementById("m_Title").innerHTML = p.Title;
                    document.getElementById("m_Type").innerHTML = p.Category + "/" + p.MediaType;
                    document.getElementById("m_Description").innerHTML = p.Description;
                    document.getElementById("m_RRP").innerHTML = '$' + parseFloat(p.RRP).toFixed(2);
                    document.getElementById("m_Price").innerHTML = '$' + parseFloat(p.Price).toFixed(2);
                    document.getElementById("m_Discount").innerHTML = '$' + parseFloat(p.Discount).toFixed(2);
                    document.getElementById("m_Image").src = '/Content/Img/Cover/' + p.Image;

                    modalContent.style.display = "block";
                    spinner.style.display = "none";
                }
                else {
                    //display error message
                    popupInfo(false, p.errorMessage, "", "");
                    spinner.style.display = "none";
                }
            }
            catch (e) {
                $("#productModal").modal("toggle");
                popupInfo(false, "there was an error parsing the JSON response text", "", "");
                spinner.style.display = "none";
                return;
            }
        }
    };

    //possibly open the modal window here 'blank' with loading message
    $("#productModal").modal("toggle");

    http.open('GET', 'http://localhost:52075/Product/GetJsonProduct/' + id, true);
    http.send();
}

function displayProductSearchModal(pid) {
    var btn_Action = document.getElementById("m_Action");
    btn_Action.setAttribute("data-pid", pid);
    btn_Action.innerHTML = 'Add To Cart';
    updateProductModal(pid);
}

function displayCartProductModal(pid, id) {
    var btn_Action = document.getElementById("m_Action");
    btn_Action.setAttribute("data-pid", id);
    btn_Action.innerHTML = 'Remove From Cart';
    updateProductModal(pid);
}

//function addCartItem_Modal(button) {
//    if (addToShoppingCart(pid)) {
//        var btn_Action = document.getElementById("m_Action");
//        btn_Action.innerHTML = 'Added To Cart ';
//    }
//}

//Majidi modal support------------------------------------------------------------------------------

function popupInfo(i_bShowSpinner, i_sMessage, i_sTitle, i_sFooter) {
    showPopup(i_bShowSpinner, i_sMessage, i_sTitle, i_sFooter, "modal-colour-normal");
}

function popupWarning(i_bShowSpinner, i_sMessage, i_sTitle, i_sFooter) {
    showPopup(i_bShowSpinner, i_sMessage, i_sTitle, i_sFooter, "modal-colour-warning");
}

function popupError(i_bShowSpinner, i_sMessage, i_sTitle, i_sFooter) {
    showPopup(i_bShowSpinner, i_sMessage, i_sTitle, i_sFooter, "modal-colour-error");
}

function showPopup(i_bShowSpinner, i_sMessage, i_sTitle, i_sFooter, i_sColourStyle) {
    i_sTitle = i_sTitle || "";
    i_sFooter = i_sFooter || "";

    var oNodeCanvas = document.getElementById("modal-container1");
    $("#modal-container1").fadeIn(300);
    oNodeCanvas.querySelector(".spinner").style.display = i_bShowSpinner ? "block" : "none";

    var oNodePopup = oNodeCanvas.querySelector(".modal-popup");
    oNodePopup.style.display = "block";
    oNodePopup.className = "modal-popup centred-xy shadow-text " + i_sColourStyle;
    oNodePopup.querySelector("header>div").innerHTML = i_sTitle;
    oNodePopup.querySelector(".modal-message").innerHTML = i_sMessage;
    oNodePopup.querySelector("footer>p").innerHTML = i_sFooter;
}

function hidePopup() {
    $("#modal-container1").fadeOut(300);
}

// Uncomment this code block to allow modal form to be closed upon click anywhere outside popup...
$("#modal-container1").on("click", function () {
    if (event.target === this) {
        $("#modal-container1").fadeOut(300);
    }    
});


