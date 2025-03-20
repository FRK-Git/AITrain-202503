import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LANG from "@salesforce/i18n/lang";

const SEARCH_DELAY = 300; //等待300毫秒后，用户停止输入，然后执行搜索

const KEY_ARROW_UP = 38;
const KEY_ARROW_DOWN = 40;
const KEY_ENTER = 13;

const VARIANT_LABEL_STACKED = 'label-stacked';//上下
const VARIANT_LABEL_INLINE = 'label-inline';//左右
const VARIANT_LABEL_HIDDEN = 'label-hidden';//隐藏

const REGEX_SOSL_RESERVED = /(\?|&|\||!|\{|\}|\[|\]|\(|\)|\^|~|\*|:|"|\+|-|\\)/g;
const REGEX_EXTRA_TRAP = /(\$|\\)/g;

export default class lookup extends NavigationMixin(LightningElement) {
    // Public properties

    @api variant = VARIANT_LABEL_STACKED;//默认上下显示
    @api label = '';//标签名
    @api objtype = '';//对象Api名
    @api anoptionalparam = '';//查询过滤条件
    @api icon = 'standard:lead_list';//默认图标
    @api minSearchTermLength = 0;//查询字符串限制
    @api required = false;//是否必填
    @api requiredMsg = '';//必填提醒内容
    @api disabled = false;//是否只读
    @api placeholder = '';//查询提醒
    @api isMultiEntry = false;//是否多选
    @api errors = [];//错误提示内容
    @api isDefaultSearch = false;//是否默认搜索
    @api scrollAfterNItems = 5;
    @api name = '';
    
    @api newRecordOptions = [];//是否创建记录
    // newRecordOptions = [
    //     { value: 'Account', label: 'New Account' },
    //     { value: 'Opportunity', label: 'New Opportunity' }
    // ];
    
    // Template properties
    searchResultsLocalState = [];//
    loading = false;

    // Private properties
    _hasFocus = false;
    _isDirty = false;//是否用户操作
    _searchTerm = '';//查询
    _cleanSearchTerm;
    _cancelBlur = false;
    _searchThrottlingTimeout;
    _searchResults = [];
    _defaultSearchResults = [];
    _curSelection = [];
    _focusedResultIndex = null;
    _requiredMsg = "";

    // 公共函数和 getter/setter
    @api
    set selection(initialSelection) {
        if (initialSelection) {
            this._curSelection = Array.isArray(initialSelection) ? initialSelection : [initialSelection];
        }else{
            this._curSelection = [];
        }
        this.processSelectionUpdate(false);
    }

    get selection() {
        return this._curSelection;
    }

    //设置查询结果
    @api
    setSearchResults(results) {
        // Reset the spinner
        this.loading = false;
        // Clone results before modifying them to avoid Locker restriction
        let resultsLocal = JSON.parse(JSON.stringify(results));
        // Remove selected items from search results
        const selectedIds = this._curSelection.map((sel) => sel.id);
        resultsLocal = resultsLocal.filter((result) => selectedIds.indexOf(result.id) === -1);
        // Format results
        const cleanSearchTerm = this._searchTerm.replace(REGEX_SOSL_RESERVED, '.?').replace(REGEX_EXTRA_TRAP, '\\$1');
        const regex = new RegExp(`(${cleanSearchTerm})`, 'gi');
        this._searchResults = resultsLocal.map((result) => {

            // Format title and subtitle
            if (this._searchTerm.length > 0) {
                result.titleFormatted = result.title
                    ? result.title.replace(regex, '<strong>$1</strong>')
                    : result.title;
                result.subtitleFormatted = result.subtitle
                    ? result.subtitle.replace(regex, '<strong>$1</strong>')
                    : result.subtitle;
            } else {
                result.titleFormatted = result.title;
                result.subtitleFormatted = result.subtitle;
            }
            // Add icon if missing
            if (result.icon === 'undefined' || result.icon === "" | result.icon === null ) {
                result.icon = this.icon;
            }
            // if (typeof result.icon === 'undefined') {
            //     result.icon = this.icon;
            // }
            return result;
        });
        // Add local state and dynamic class to search results
        this._focusedResultIndex = null;
        const self = this;
        this.searchResultsLocalState = this._searchResults.map((result, i) => {
            return {
                result,
                state: {},
                get classes() {
                    let cls =
                        'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta';
                    if (self._focusedResultIndex === i) {
                        cls += ' slds-has-focus';
                    }
                    return cls;
                }
            };
        });
    }
    //获取选中的内容
    @api
    getSelection() {
        return this._curSelection;
    }
    //设置最近浏览内容
    @api
    setDefaultResults(results) {
        this._defaultSearchResults = [...results];
        if (this._searchResults.length === 0) {
            this.setSearchResults(this._defaultSearchResults);
        }
    }

    get getLabel() {
        if (this.label != null && this.label != '') {
            return true;
        }else {
            return false;
        }
    }

    // INTERNAL FUNCTIONS

    updateSearchTerm(newSearchTerm) {
        this._searchTerm = newSearchTerm;
        
        // Compare clean new search term with current one and abort if identical
        const newCleanSearchTerm = newSearchTerm.trim().replace(REGEX_SOSL_RESERVED, '?').toLowerCase();
        if (this._cleanSearchTerm === newCleanSearchTerm && !this.isDefaultSearch) {
            return;
        }

        // Save clean search term
        this._cleanSearchTerm = newCleanSearchTerm;

        // Ignore search terms that are too small after removing special characters
        if (newCleanSearchTerm.replace(/\?/g, '').length < this.minSearchTermLength
            && !this.isDefaultSearch) {
            this.setSearchResults(this._defaultSearchResults);
            return;
        }

        // Apply search throttling (prevents search if user is still typing)
        if (this._searchThrottlingTimeout) {
            clearTimeout(this._searchThrottlingTimeout);
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._searchThrottlingTimeout = setTimeout(() => {
            // Send search event if search term is long enougth
            if (this._cleanSearchTerm.length >= this.minSearchTermLength
                || this.isDefaultSearch) {
                // Display spinner until results are returned
                this.loading = true;

                const searchEvent = new CustomEvent('search', {
                    detail: {
                        // searchTerm: this._cleanSearchTerm,
                        searchTerm: newSearchTerm,
                        selectedIds: this._curSelection.map((element) => element.id),
                        objType : this.objtype,
                        anOptionalParam : this.anoptionalparam
                    }
                });
                this.dispatchEvent(searchEvent);
            }
            this._searchThrottlingTimeout = null;
        }, SEARCH_DELAY);
    }

    isSelectionAllowed() {
        if (this.isMultiEntry) {
            return true;
        }
        return !this.hasSelection();
    }

    hasSelection() {
        // console.log(this._curSelection.length)
        return this._curSelection.length > 0;
    }

    processSelectionUpdate(isUserInteraction) {
        // 重置搜索
        this._cleanSearchTerm = '';
        this._searchTerm = '';
        this.setSearchResults([...this._defaultSearchResults]);
        // Indicate that component was interacted with
        this._isDirty = isUserInteraction;
        // Blur input after single select lookup selection
        if (!this.isMultiEntry && this.hasSelection()) {
            this._hasFocus = false;
        }
        // If selection was changed by user, notify parent components
        if (isUserInteraction) {
            // const selectedIds = this._curSelection.map((sel) => sel.id);
            // this.dispatchEvent(new CustomEvent('selectionchange', { detail: selectedIds }));
            const selectedIds = this._curSelection.map((sel) => sel.id);
            this.dispatchEvent(new CustomEvent('selectionchange', { detail: { "selectedIds":selectedIds,"selection": this._curSelection,"objType":this.objtype } }));
        }
    }

    // EVENT HANDLING
    handleInput(event) {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.updateSearchTerm(event.target.value);
    }

    handleKeyDown(event) {
        if (this._focusedResultIndex === null) {
            this._focusedResultIndex = -1;
        }
        if (event.keyCode === KEY_ARROW_DOWN) {
            // If we hit 'down', select the next item, or cycle over.
            this._focusedResultIndex++;
            if (this._focusedResultIndex >= this._searchResults.length) {
                this._focusedResultIndex = 0;
            }
            event.preventDefault();
        } else if (event.keyCode === KEY_ARROW_UP) {
            // If we hit 'up', select the previous item, or cycle over.
            this._focusedResultIndex--;
            if (this._focusedResultIndex < 0) {
                this._focusedResultIndex = this._searchResults.length - 1;
            }
            event.preventDefault();
        } else if (event.keyCode === KEY_ENTER && this._hasFocus && this._focusedResultIndex >= 0) {
            // If the user presses enter, and the box is open, and we have used arrows,
            // treat this just like a click on the listbox item
            const selectedId = this._searchResults[this._focusedResultIndex].id;
            this.template.querySelector(`[data-recordid="${selectedId}"]`).click();
            event.preventDefault();
        }
    }

    //选中查询项后调用的方法
    handleResultClick(event) {
        const recordId = event.currentTarget.dataset.recordid;

        // Save selection
        const selectedItem = this._searchResults.find((result) => result.id === recordId);
        if (!selectedItem) {
            return;
        }
        const newSelection = [...this._curSelection];
        newSelection.push(selectedItem);
        this._curSelection = newSelection;
        this.errors = [];
        // Process selection update
        this.processSelectionUpdate(true);
    }

    handleComboboxMouseDown(event) {
        const mainButton = 0;
        if (event.button === mainButton) {
            this._cancelBlur = true;
        }
    }

    handleComboboxMouseUp() {
        this._cancelBlur = false;
        // Re-focus to text input for the next blur event
        this.template.querySelector('input').focus();
    }

    handleFocus() {
        if(this.isDefaultSearch){
            this.updateSearchTerm('');
        }
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this._hasFocus = true;
        this._focusedResultIndex = null;
    }

    handleBlur() {
        // Prevent action if selection is either not allowed or cancelled
        if (!this.isSelectionAllowed() || this._cancelBlur) {
            return;
        }
        this._hasFocus = false;
        this._isDirty = true;
        this.checkRequiredError();
    }

    handleRemoveSelectedItem(event) {
        if (this.disabled) {
            return;
        }
        const recordId = event.currentTarget.name;
        this._curSelection = this._curSelection.filter((item) => item.id !== recordId);
        this.checkRequiredError();
        // Process selection update
        this.processSelectionUpdate(true);
    }

    handleClearSelection() {
        this._curSelection = [];
        this._hasFocus = false;
        this.checkRequiredError();
        // Process selection update
        this.processSelectionUpdate(true);
    }

    checkRequiredError() {
        
        if(this._curSelection.length <= 0 && this.required){
            this.errors = [{id:"requiredError",message:this.handleRequiredMsg()}];
        }
    }

    @api
    checkRequiredErrorValue(isReCheck) {
        console.log(this._curSelection.length);
        if(this._curSelection.length <= 0 && this.required){
            this.errors = [{id:"requiredError",message:this.handleRequiredMsg()}];
            return false;
        }
        if (isReCheck) {
            this.errors = [];
            // Process selection update
            this.processSelectionUpdate(false);
        }
        
        return true;
    }


    handleRequiredMsg() {
        if(this.requiredMsg != undefined && this.requiredMsg != '' && this.requiredMsg != null){
            this._requiredMsg = this.requiredMsg;
        }else if( LANG == 'zh-Hans-CN' || LANG == 'zh-CN' ){
            this._requiredMsg = "填写此字段。";
        }else if( LANG == 'zh-Hant-CN' || LANG == 'zh-Hant-TW'){
            this._requiredMsg = "完成此欄位。";
        }else{
            this._requiredMsg = "Complete this field.";
        }
        return this._requiredMsg;
    }

    handleNewRecordClick(event) {
        const objectApiName = event.currentTarget.dataset.sobject;
        const selection = this.newRecordOptions.find((option) => option.value === objectApiName);

        const preNavigateCallback = selection.preNavigateCallback
            ? selection.preNavigateCallback
            : () => Promise.resolve();
        preNavigateCallback(selection).then(() => {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName,
                    actionName: 'new'
                },
                state: {
                    defaultFieldValues: selection.defaults
                }
            });
        });
    }


    // STYLE EXPRESSIONS

    get hasResults() {
        return this._searchResults.length > 0;
    }

    get getFormElementClass() {
        return this.variant === VARIANT_LABEL_INLINE
            ? 'slds-form-element slds-form-element_horizontal'
            : 'slds-form-element';
    }

    get getLabelClass() {
        return this.variant === VARIANT_LABEL_HIDDEN
            ? 'slds-form-element__label slds-assistive-text'
            : 'slds-form-element__label';
    }

    get getContainerClass() {
        let css = 'slds-combobox_container ';
        if (this.errors.length > 0) {
            css += 'has-custom-error';
        }
        return css;
    }

    get getDropdownClass() {
        let css = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
        const isSearchTermValid = this._cleanSearchTerm && this._cleanSearchTerm.length >= this.minSearchTermLength;
        if (this._hasFocus && this.isSelectionAllowed() && (isSearchTermValid || this.hasResults)) {
            css += 'slds-is-open';
        }
        return css;
    }

    get getInputClass() {
        let css = 'slds-input slds-combobox__input has-custom-height ';
        if (this._hasFocus && this.hasResults) {
            css += 'slds-has-focus ';
        }
        if (this.errors.length > 0 || (this._isDirty && this.required && !this.hasSelection())) {
            css += 'has-custom-error ';
        }
        if (!this.isMultiEntry) {
            css += 'slds-combobox__input-value ' + (this.hasSelection() ? 'has-custom-border' : '');
        }
        return css;
    }

    get getComboboxClass() {
        let css = 'slds-combobox__form-element slds-input-has-icon ';
        if (this.isMultiEntry) {
            css += 'slds-input-has-icon_right';
        } else {
            css += this.hasSelection() ? 'slds-input-has-icon_left-right' : 'slds-input-has-icon_right';
        }
        return css;
    }

    get getSearchIconClass() {
        let css = 'slds-input__icon slds-input__icon_right ';
        if (!this.isMultiEntry) {
            css += this.hasSelection() ? 'slds-hide' : '';
        }
        return css;
    }

    get getClearSelectionButtonClass() {
        return (
            'slds-button slds-button_icon slds-input__icon slds-input__icon_right ' +
            (this.hasSelection() ? '' : 'slds-hide')
        );
    }

    get getSelectIconName() {
        // console.log(this._curSelection);
        // console.log(this.hasSelection());
        return this.hasSelection() ? this._curSelection[0].icon : 'standard:default';
    }

    get getSelectIconClass() {
        return 'slds-combobox__input-entity-icon ' + (this.hasSelection() ? '' : 'slds-hide');
    }

    get getInputValue() {
        if (this.isMultiEntry) {
            return this._searchTerm;
        }
        return this.hasSelection() ? this._curSelection[0].title : this._searchTerm;
    }

    get getInputTitle() {
        if (this.isMultiEntry) {
            return '';
        }
        return this.hasSelection() ? this._curSelection[0].title : '';
    }

    get getListboxClass() {
        return (
            'slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid ' +
            (this.scrollAfterNItems ? `slds-dropdown_length-with-icon-${this.scrollAfterNItems} ` : '')
        );
    }

    get isInputReadonly() {
        if (this.isMultiEntry) {
            return false;
        }
        return this.hasSelection();
    }
}