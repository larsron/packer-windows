#!/usr/bin/env bash

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

set -e

follow_link() {
  FILE="$1"
  while [ -h "$FILE" ]; do
    # On Mac OS, readlink -f doesn't work.
    FILE="$(readlink "$FILE")"
  done
  echo "$FILE"
}

VAGRANT_BOX_PATH=$HOME/vagrant/boxes
SCRIPT_PATH=$(realpath "$(dirname "$(follow_link "$0")")")
CONFIG_PATH=$(realpath "${1:-${SCRIPT_PATH}/config}")

mkdir -p "$VAGRANT_BOX_PATH"

menu_option_1() {
  VAGRANT_PROVIDER="parallels"
  INPUT_PATH="$SCRIPT_PATH"/builds/windows-10/
  echo -e "\nCONFIRM: Build Microsoft Windows 10 Enterprise Template for Parallels?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build Microsoft Windows 10 Enterprise for Parallels. ###
  echo "Building a Microsoft Microsoft Windows 10 Enterprise Template for Parallels..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the HashiCorp Packer Build ###
  echo "Starting the HashiCorp Packer build..."
  PKR_VAR_VAGRANT_PROVIDER=$VAGRANT_PROVIDER \
  PKR_VAR_VAGRANT_BOX_PATH=$VAGRANT_BOX_PATH \
  packer build -only=parallels-iso.* -force \
      -var-file="$CONFIG_PATH/parallels.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

menu_option_2() {
  VAGRANT_PROVIDER="libvirt"
  INPUT_PATH="$SCRIPT_PATH"/builds/windows-10/
  echo -e "\nCONFIRM: Build Microsoft Windows 10 Enterprise Eval Template for QEMU?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Download the Windows VirtIO Drivers. ###
  echo "Downloading the Windows VirtIO Drivers..."
	EXIT_CODE=0
  wget -nv -nc https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso -O virtio-win.iso || EXIT_CODE=$?
  rm -rf drivers.tmp
	mkdir -p drivers.tmp
  cp virtio-win.iso drivers.tmp/.
  7z x -odrivers.tmp drivers.tmp/virtio-win.iso
  rm -rf drivers
	mv drivers.tmp drivers

  ### Build Microsoft Windows 10 Enterprise for QEMU. ###
  echo "Building a Microsoft Windows 10 Enterprise Eval Template for QEMU..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the HashiCorp Packer Build ###
  echo "Starting the HashiCorp Packer build..."
  PKR_VAR_VAGRANT_PROVIDER=$VAGRANT_PROVIDER \
  PKR_VAR_VAGRANT_BOX_PATH=$VAGRANT_BOX_PATH \
  packer build -only=qemu.* -force \
      -var-file="$CONFIG_PATH/qemu.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}

press_enter() {
  cd "$SCRIPT_PATH"
  echo -n "Press Enter to continue."
  read -r
  clear
}

incorrect_selection() {
  echo "Do or do not. There is no try."
}

until [ "$selection" = "0" ]; do
  clear
  echo -n "  Select a Packer build:"
  echo ""
  echo ""
  echo "      Microsoft Windows:"
  echo ""
  echo "    	 1  -  Windows 10 Enterprise Eval (Parallels)"
  echo "    	 2  -  Windows 10 Enterprise Eval (QEMU)"
  echo ""
  echo "      Other:"
  echo ""
  echo "        Q   -  Quit"
  echo ""
  read -r selection
  echo ""
  case $selection in
    1 ) clear ; menu_option_1 ; press_enter ;;
    2 ) clear ; menu_option_2 ; press_enter ;;
    Q ) clear ; exit ;;
    * ) clear ; incorrect_selection ; press_enter ;;
  esac
done