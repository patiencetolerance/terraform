/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


variable "project" {
  description = "The ID of the project in which the resource deployed too."
}

variable "name" {
  description = "Name of the internal-ip. the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])?"
}

variable "network" {
  description = "The URL of the network in which to reserve the IP range.This should only be set when using an Internal address."
  default     = ""
}

variable "address_type" {
  description = "EXTERNAL indicates public/external single IP address. INTERNAL indicates internal IP ranges belonging to some network."
  default     = "EXTERNAL"
}

variable "description" {
  description = "An optional description of this resource."
  default     = ""
}

variable "purpose" {
  description = "The purpose of the resource. Possible values include: VPC_PEERING - for peer networks, PRIVATE_SERVICE_CONNECT"
  default     = ""
}

variable "prefix_length" {
  description = "The prefix length of the IP range.This field is not applicable to addresses with addressType=EXTERNAL."
  default     = 0
}


