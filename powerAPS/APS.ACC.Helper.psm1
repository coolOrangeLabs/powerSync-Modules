#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2025 COOLORANGE S.r.l.                                         #
#==============================================================================#




# Iterates through all pages of results
function Get-AllApsAccResults($parameters){
    $ret = @()
    $continuation = $null
    do {
        $newURI = $continuation
        if ($null -ne $newUri){
            $parameters["Uri"] = $newURI
        }
        $response = Invoke-RestMethod @parameters
        $ret += $response.results
        $continuation = $response.pagination.nextUrl
    }
    while($null -ne $continuation)

    return $ret
}

# TODO: add in logic for adding to end of URI.
function Add-ToUri([string]$uri, [hashtable]$queryParameters){
    if ($null -eq $queryParameters -or $queryParameters.Keys.count -eq 0){
        return $uri
    }
}

function ShowPowerSyncErrorMessage($err){
    [System.Windows.MessageBox]::Show(
        $err.message, 
        $err.title, 
        "OK", 
        "Error")
    return
}

$sourceMI = @'

using System.ComponentModel;

namespace powerSync
{
    public class MappingItem : INotifyPropertyChanged
    {
        private string _acc;
        private string _vault;

        public string Acc
        {
            get { return _acc; }
            set
            {
                if (_acc != value)
                {
                    _acc = value;
                    OnPropertyChanged("Acc");
                }
            }
        }

        public string Vault
        {
            get { return _vault; }
            set
            {
                if (_vault != value)
                {
                    _vault = value;
                    OnPropertyChanged("Vault");
                }
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;

        protected void OnPropertyChanged(string propertyName)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
            }
        }
    }
}
'@
Add-Type $sourceMI





$sourceER = @'
using System.Windows;

namespace powerSync
{
    public class Error
    {
        public string Message { get; set; }
        public string Title { get; set; }
        public string Type { get; set; }

        public Error(string message, string title, string type = "Error")
        {
            Message = message;
            Title = title;
            Type = type;
        }

        public override string ToString()
        {
            return Message;
        }
    }
}

'@
Add-Type $sourceER

$sourceTVN = @'
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace powerSync
{
    public class TreeViewNode : INotifyPropertyChanged
    {
        public delegate void LoadChildrenHandler(object sender);
        public event LoadChildrenHandler LoadChildren;

        private readonly bool _isDummy;
        private string _name;
        private bool _isExpanded;
        private bool _isSelected;
        private TreeViewNode _parent;

        public event PropertyChangedEventHandler PropertyChanged;

        private void NotifyPropertyChanged([CallerMemberName] string propertyName = "")
        {
            if (PropertyChanged != null){
                PropertyChanged.Invoke(this, new PropertyChangedEventArgs(propertyName));
            }
        }

        public TreeViewNode()
        {
            _isDummy = true;
        }

        public TreeViewNode(TreeViewNode parent, bool isOutmost = false)
        {
            Parent = parent;
            if (isOutmost)
                Children = new ObservableCollection<TreeViewNode>();
            else
                Children = new ObservableCollection<TreeViewNode> { new TreeViewNode() };
        }

        public TreeViewNode Parent
        {
            get {
                return _parent;
            }
            set{
                _parent = value;
            } 
        }

        public ObservableCollection<TreeViewNode> Children { get; set; }

        public string Name
        {
            get{
                return _name;
            }
            set
            {
                if (value != _name)
                {
                    _name = value;
                    NotifyPropertyChanged();
                }
            }
        }

        public object Type { get; set; }

        public bool IsExpanded
        {
            get{
                return _isExpanded;
            }
            set
            {
                if (value != _isExpanded)
                {
                    _isExpanded = value;
                    NotifyPropertyChanged();

                    if (Children.Count == 1 && Children[0]._isDummy)
                    {
                        if (LoadChildren == null)
                            return;

                        Children.Clear();
                        LoadChildren(this);
                    }
                }

                if (_isExpanded && _parent != null)
                    _parent.IsExpanded = true;
            }
        }

        public bool IsSelected
        {
            get{
                return _isSelected;
            }
            set
            {
                if (value != _isSelected)
                {
                    _isSelected = value;
                    NotifyPropertyChanged();
                }
            }
        }

        public object Object { get; set; }
    }
}
'@

Add-Type $sourceTVN

# class PowerSyncError{
#     [string]$message
#     [string]$title
#     [string]$type

#     PowerSyncError([string]$_message, [string]$_title, [string]$_type){
#         $this.message = $_message
#         $this.title = $_title
#         $this.type = $_type
#     }

#     ShowErrorMessage(){
#         [System.Windows.MessageBox]::Show(
#             $this.message, 
#             $this.title, 
#             "OK", 
#             "Error")
#         return
#     }

# }